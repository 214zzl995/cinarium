use std::{
    collections::HashSet,
    hash::{Hash, Hasher},
    path::{Path, PathBuf},
    sync::OnceLock,
};

use flutter_rust_bridge::DartFnFuture;
use notify::{
    event::{ModifyKind, RenameMode},
    Config, Error, Event, RecommendedWatcher, Watcher,
};
use tokio::sync::{
    broadcast,
    mpsc::{unbounded_channel, UnboundedReceiver, UnboundedSender},
    oneshot, Mutex,
};

use crate::{
    model::{Metadata, Source},
    native::ListenerHandle,
};

static SOURCE_NOTIFY: OnceLock<Mutex<SourceNotify>> = OnceLock::new();
static LISTENER: OnceLock<broadcast::Sender<()>> = OnceLock::new();

struct SourceNotify {
    watcher: RecommendedWatcher,
    sources: Vec<Source>,
    modifys: HashSet<PathBuf>,
}

pub async fn init_source_notify() -> anyhow::Result<()> {

    if SOURCE_NOTIFY.get().is_some() {
        return Ok(());
    }

    let sources = Source::query_all().await?;

    let (tx, rx) = unbounded_channel();

    SOURCE_NOTIFY
        .set(Mutex::new(SourceNotify::new(&sources, tx)?))
        .map_err(|_| anyhow::anyhow!("Failed to set source notify"))?;

    let mut source_notify = SOURCE_NOTIFY.get().unwrap().lock().await;
    source_notify.full_scale_retrieval().await?;
    source_notify.listen(rx).await;

    Ok(())
}

impl SourceNotify {
    fn new(
        sources: &[Source],
        tx: UnboundedSender<std::result::Result<Event, Error>>,
    ) -> anyhow::Result<Self> {
        let watcher = RecommendedWatcher::new(
            move |result: std::result::Result<Event, Error>| {
                tx.send(result).expect("Failed to send event");
            },
            Config::default(),
        )?;

        Ok(SourceNotify {
            watcher,
            sources: sources.to_owned(),
            modifys: HashSet::new(),
        })
    }

    fn add_modify_path(&mut self, path: PathBuf) {
        self.modifys.insert(path);
    }

    async fn listen(&mut self, mut rx: UnboundedReceiver<Result<Event, Error>>) {
        tokio::spawn(async move {
            while let Some(Ok(event)) = rx.recv().await {
                match event.kind {
                    notify::EventKind::Create(_) => {
                        let path = event.paths.first().unwrap().clone();
                        if !path.is_file() {
                            continue;
                        }
                        #[cfg(target_os = "windows")]
                        if is_recycle_bin(&path) {
                            continue;
                        }
                        if is_mov_type(path.extension().unwrap().to_str().unwrap()) {}
                    }
                    notify::EventKind::Remove(_) => {
                        let path = event.paths.first().unwrap().clone();
                        // Files that have been deleted will get a non-file judgment because of the lack of metadata
                        if path.extension().is_none() {
                            continue;
                        }
                        #[cfg(target_os = "windows")]
                        if is_recycle_bin(&path) {
                            continue;
                        }

                        if is_mov_type(path.extension().unwrap().to_str().unwrap()) {
                            tokio::spawn(async move {
                                let _ = Metadata::marking_delete_with_path(&path).await;
                            });
                        }
                    }
                    notify::EventKind::Modify(modify_kind) => {
                        if modify_kind == ModifyKind::Any
                            || modify_kind == ModifyKind::Name(RenameMode::To)
                        {
                            let path = event.paths.first().unwrap().clone();

                            if !path.is_file() {
                                continue;
                            }
                            #[cfg(target_os = "windows")]
                            if is_recycle_bin(&path) {
                                continue;
                            }

                            if is_mov_type(path.extension().unwrap().to_str().unwrap()) {
                                SOURCE_NOTIFY
                                    .get()
                                    .unwrap()
                                    .lock()
                                    .await
                                    .add_modify_path(path);
                            }
                        }
                    }
                    _ => {}
                }
            }
        });

        for source in self.sources.iter() {
            self.watcher
                .watch(
                    std::path::Path::new(&source.path),
                    ::notify::RecursiveMode::Recursive,
                )
                .unwrap();
        }

        // n seconds to assemble an update statement Prevents transactions from being too frequent
        tokio::spawn(async move {
            loop {
                tokio::time::sleep(tokio::time::Duration::from_secs(5)).await;
                let modifys = {
                    let mut source_notify = SOURCE_NOTIFY.get().unwrap().lock().await;
                    source_notify.modifys.drain().collect::<Vec<PathBuf>>()
                }
                .into_iter()
                .filter_map(|path| match Metadata::try_from(&path) {
                    Ok(metadata) => Some(metadata),
                    // Possible scenario: File busy
                    Err(_) => None,
                })
                .collect::<Vec<Metadata>>();
                if !modifys.is_empty() {
                    Metadata::insert_replace_batch(&modifys).await.unwrap();
                }
            }
        });
    }

    async fn full_scale_retrieval(&self) -> anyhow::Result<()> {
        let phy_videos: HashSet<(String, PathBuf)> = self
            .sources
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

        if !new_videos.is_empty() || !deleted_videos.is_empty() {
            let _ = LISTENER
                .get_or_init(|| {
                    let (tx, _) = broadcast::channel(1);
                    tx
                })
                .send(());
        }

        Ok(())
    }
}

#[cfg(target_os = "windows")]
fn is_recycle_bin(path: &Path) -> bool {
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

fn is_mov_type(extension: &str) -> bool {
    matches!(
        extension,
        "mov" | "mp4" | "mkv" | "avi" | "wmv" | "flv" | "rmvb" | "rm" | "3gp"
    )
}

fn get_file_id_hash(path: &impl AsRef<Path>) -> anyhow::Result<String> {
    let file_id = file_id::get_file_id(path)?;
    let mut hasher = std::hash::DefaultHasher::new();
    file_id.hash(&mut hasher);
    Ok(format!("{:x}", hasher.finish()))
}

pub fn listener_untreated_file(
    dart_callback: impl Fn() -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    let (handle_tx, handle_rx) = oneshot::channel::<()>();
    tokio::spawn(async move {
        let mut rx = LISTENER
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
