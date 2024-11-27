use std::{
    collections::HashSet,
    hash::{Hash, Hasher},
    path::{Path, PathBuf},
    sync::{Arc, OnceLock},
};

use anyhow::anyhow;
use flutter_rust_bridge::{frb, DartFnFuture};
use parking_lot::RwLock;
use tokio::sync::{
    broadcast,
    mpsc::{self},
    oneshot, watch,
};

use crate::{
    model::{Metadata, Source, UntreatedVideo},
    native::ListenerHandle,
};

mod notify;

static UNTREATED_FILE_LISTENER: OnceLock<broadcast::Sender<()>> = OnceLock::new();
static STORAGE_SCAN_LISTENER: OnceLock<watch::Sender<bool>> = OnceLock::new();

pub struct UntreatedVideoDataInner {
    notify: notify::SourceNotify,
    event_tx: tokio::sync::mpsc::Sender<UntreatedVideoEvent>,
    dispose_tx: broadcast::Sender<()>,
    pub(crate) videos: Vec<UntreatedVideo>,
    pub text_filter: String,
}

#[derive(Clone)]
#[frb(opaque)]
pub struct UntreatedVideoData {
    pub(crate) inner: Arc<RwLock<UntreatedVideoDataInner>>,
}

pub enum UntreatedVideoEvent {
    InsertOrUpdate(Vec<Metadata>),
    Remove(Vec<PathBuf>),
}

impl UntreatedVideoEvent {}

impl UntreatedVideoData {
    pub async fn new() -> anyhow::Result<Self> {
        let (dispose_tx, _) = broadcast::channel(16);
        let (return_tx, return_rx) = mpsc::channel(1);
        let (event_tx, event_rx) = mpsc::unbounded_channel();

        let sources = Source::query_all().await?;
        let notify = notify::SourceNotify::new(&sources, event_tx)?;

        let self_ = UntreatedVideoData {
            inner: Arc::new(RwLock::new(UntreatedVideoDataInner {
                videos: vec![],
                notify: notify.clone(),
                text_filter: "".to_string(),
                event_tx: return_tx.clone(),
                dispose_tx: dispose_tx.clone(),
            })),
        };
        self_.inner.write().videos = UntreatedVideo::query_all().await?;

        // let self__ = self_.clone();

        self_.full_scale_retrieval(&sources).await.unwrap();
        self_.event_start(return_rx);
        self_
            .inner
            .read()
            .notify
            .listen(return_tx, event_rx, dispose_tx.clone());

        Ok(self_)
    }

    fn event_start(&self, mut event_rx: tokio::sync::mpsc::Receiver<UntreatedVideoEvent>) {
        let self_ = self.clone();
        tokio::spawn(async move {
            let event = async {
                while let Some(event) = event_rx.recv().await {
                    match event {
                        UntreatedVideoEvent::InsertOrUpdate(metadatas) => {
                            let untreated_videos =
                                Metadata::insert_replace_batch(&metadatas).await.unwrap();
                            self_.inner.write().videos.extend(untreated_videos);
                        }
                        UntreatedVideoEvent::Remove(deletes) => {
                            let delete_ids =
                                Metadata::marking_delete_with_paths(&deletes).await.unwrap();

                            self_
                                .inner
                                .write()
                                .videos
                                .retain(|v| !delete_ids.contains(&v.id));
                        }
                    }
                }
            };
            let dispose = async {
                let mut dispose_rx = self_.inner.read().dispose_tx.subscribe();
                dispose_rx.recv().await.ok();
            };
            tokio::select! {
                _ = dispose => {},
                _ = event => {},
            };
        });
    }

    pub(crate) async fn watch_source(&self, path: &PathBuf) -> anyhow::Result<()> {
        let source = Source::insert(path).await?;

        let sources = self.inner.read().notify.sources();

        for source_item in sources {
            if source_item.path.eq(path) {
                return Err(anyhow!("The directory already exists"));
            }

            if path.starts_with(&source_item.path) {
                return Err(anyhow!("The parent directory already exists"));
            }

            if source_item.path.starts_with(path) {
                self.unwatch_source(&source_item, &false).await?;
                source_item.change_source_id(source.id).await?;
            }
        }

        let path = path.clone();

        let self_ = self.clone();

        tokio::spawn(async move {
            let tx = STORAGE_SCAN_LISTENER.get().unwrap();
            tx.send_replace(true);

            let new_videos = retrieve_phy_videos(&path)
                .unwrap()
                .into_iter()
                .map(|(_, p)| Metadata::try_from(&p))
                .collect::<Result<Vec<_>, _>>()
                .unwrap();

            if !new_videos.is_empty() {
                let untreated_videos = Metadata::insert_replace_batch(&new_videos).await.unwrap();
                self_.inner.write().videos.extend(untreated_videos);
            }

            tx.send_replace(false);
        });

        self.inner.read().notify.watch_source(&source)
    }

    pub(crate) async fn unwatch_source(
        &self,
        source: &Source,
        sync_delete: &bool,
    ) -> anyhow::Result<()> {
        source.delete().await?;
        if *sync_delete {
            let delete_ids = Metadata::delete_by_source_id(&source.id).await?;

            self.inner
                .write()
                .videos
                .retain(|v| !delete_ids.contains(&v.id));

            UNTREATED_FILE_LISTENER.get().unwrap().send(()).unwrap();
        }
        self.inner.read().notify.unwatch_source(source)
    }

    pub fn get_sources(&self) -> anyhow::Result<Vec<Source>> {
        Ok(self.inner.read().notify.sources())
    }

    pub(super) async fn full_scale_retrieval(&self, sources: &Vec<Source>) -> anyhow::Result<()> {
        let tx = STORAGE_SCAN_LISTENER.get_or_init(|| {
            let (tx, _) = watch::channel(false);
            tx
        });

        tx.send_replace(true);

        let phy_videos: HashSet<(String, PathBuf)> = sources
            .iter()
            .map(|source| retrieve_phy_videos(&source.path))
            .collect::<Result<Vec<_>, _>>()?
            .into_iter()
            .flatten()
            .collect();

        let db_videos: HashSet<(String, PathBuf)> = Metadata::query_all_path().await?;

        let deleted_videos: Vec<String> = db_videos
            .difference(&phy_videos)
            .map(|(h, _)| h.clone())
            .collect();

        let new_videos: Vec<Metadata> = phy_videos
            .difference(&db_videos)
            .map(|(_, p)| Metadata::try_from(p))
            .collect::<Result<Vec<_>, _>>()?;

        if !new_videos.is_empty() {
            Metadata::insert_replace_batch(&new_videos).await?;
        }
        if !deleted_videos.is_empty() {
            Metadata::marking_delete_batch_with_hash(&deleted_videos).await?;
        }

        if !new_videos.is_empty() || !deleted_videos.is_empty() {}

        tx.send_replace(false);

        Ok(())
    }
}

fn send_untreated_file_event() {
    if let Err(err) = UNTREATED_FILE_LISTENER
        .get_or_init(|| {
            let (tx, _) = broadcast::channel(1);
            tx
        })
        .send(())
    {
        tracing::error!("Failed to send event: {:?}", err);
    };
}

fn retrieve_phy_videos(source: &Path) -> anyhow::Result<Vec<HashPath>> {
    let (ok_videos, err_videos): (Vec<anyhow::Result<HashPath>>, Vec<anyhow::Result<HashPath>>) =
        walkdir::WalkDir::new(source)
            .into_iter()
            .filter_map(|e| {
                e.ok().and_then(|entry| {
                    #[cfg(target_os = "windows")]
                    if is_recycle_bin(entry.path()) {
                        return None;
                    }

                    if entry.file_type().is_file() {
                        entry.path().extension().and_then(|ex| {
                            if is_mov_type(ex.to_str().unwrap()) {
                                match get_file_id_hash(&entry.path()) {
                                    Ok(hash) => Some(Ok((hash, entry.path().to_owned()))),
                                    Err(e) => Some(Err(e)),
                                }
                            } else {
                                None
                            }
                        })
                    } else {
                        None
                    }
                })
            })
            .partition(Result::is_ok);

    if !err_videos.is_empty() {
        let combined_error = anyhow::anyhow!("Error reading file:\n{:?}", err_videos);
        Err(combined_error)
    } else {
        Ok(ok_videos.into_iter().map(Result::unwrap).collect())
    }
}

pub fn listener_untreated_file(
    dart_callback: impl Fn() -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    let (handle_tx, handle_rx) = oneshot::channel::<()>();
    tokio::spawn(async move {
        let mut rx = UNTREATED_FILE_LISTENER
            .get_or_init(|| {
                let (tx, _) = broadcast::channel(1);
                tx
            })
            .subscribe();

        let linstener = async {
            while rx.recv().await.is_ok() {
                dart_callback().await;
            }
        };

        tokio::select! {
            _ = handle_rx => {},
            _ = linstener => {},
        };
    });
    ListenerHandle::new(handle_tx)
}

pub fn listener_scan_storage(
    dart_callback: impl Fn(bool) -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    let (handle_tx, handle_rx) = oneshot::channel::<()>();
    tokio::spawn(async move {
        let mut rx = STORAGE_SCAN_LISTENER
            .get_or_init(|| {
                let (tx, _) = watch::channel(false);
                tx
            })
            .subscribe();

        let linstener = async {
            while let Ok(()) = rx.changed().await {
                let status = *rx.borrow_and_update();
                dart_callback(status).await;
            }
        };

        tokio::select! {
            _ = handle_rx => {},
            _ = linstener => {},
        };
    });
    ListenerHandle::new(handle_tx)
}

#[cfg(target_os = "windows")]
pub(in crate::file) fn is_recycle_bin(path: &Path) -> bool {
    path.components()
        .nth(2)
        .is_some_and(|com| com.as_os_str().to_str().unwrap_or("").eq("$RECYCLE.BIN"))
}

impl TryFrom<&PathBuf> for Metadata {
    type Error = anyhow::Error;

    fn try_from(path: &PathBuf) -> Result<Self, Self::Error> {
        let hash = get_file_id_hash(&path)?;
        let filename = path.file_stem().unwrap().to_str().unwrap().to_string();
        let extension = path.extension().unwrap().to_str().unwrap().to_string();
        let size = path.metadata().unwrap().len();
        let path = path.parent().unwrap().to_path_buf();

        Ok(Metadata {
            hash,
            path,
            filename,
            extension,
            size,
        })
    }
}

type HashPath = (String, PathBuf);

pub(in crate::file) fn is_mov_type(extension: &str) -> bool {
    matches!(
        extension,
        "mov" | "mp4" | "mkv" | "avi" | "wmv" | "flv" | "rmvb" | "rm" | "3gp"
    )
}

pub(in crate::file) fn get_file_id_hash(path: &impl AsRef<Path>) -> anyhow::Result<String> {
    let file_id = file_id::get_file_id(path)?;
    let mut hasher = std::hash::DefaultHasher::new();
    file_id.hash(&mut hasher);
    Ok(format!("{:x}", hasher.finish()))
}

pub fn get_scan_storage_status() -> bool {
    *STORAGE_SCAN_LISTENER
        .get_or_init(|| {
            let (tx, _) = watch::channel(false);
            tx
        })
        .borrow()
}
