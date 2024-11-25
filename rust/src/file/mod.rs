use std::{
    path::PathBuf,
    sync::{atomic::AtomicBool, Arc, OnceLock},
};

use flutter_rust_bridge::{frb, DartFnFuture};
use parking_lot::RwLock;
use tokio::sync::{
    broadcast,
    mpsc::{self},
    oneshot, OnceCell,
};

use crate::{
    model::{Metadata, Source, UntreatedVideo},
    native::ListenerHandle,
};

mod notify;

pub use notify::{get_scan_storage_status, listener_scan_storage};

static UNTREATED_VIDEO_DATA: OnceCell<RwLock<UntreatedVideoData>> = OnceCell::const_new();
static UNTREATED_FILE_LISTENER: OnceLock<broadcast::Sender<()>> = OnceLock::new();
static UNTREATED_VIDEO_INIT: AtomicBool = AtomicBool::new(false);

pub async fn untreated_video_data() -> anyhow::Result<UntreatedVideoData> {
    Ok(UNTREATED_VIDEO_DATA
        .get_or_try_init(|| async {
            match UntreatedVideoData::new().await {
                Ok(data) => {
                    UNTREATED_VIDEO_INIT.store(true, std::sync::atomic::Ordering::Relaxed);
                    anyhow::Ok(RwLock::new(data))
                }
                Err(err) => Err(err),
            }
        })
        .await?
        .read()
        .clone())
}

#[derive(Clone)]
#[frb(opaque)]
pub struct UntreatedVideoData {
    videos: Vec<UntreatedVideo>,
    pub text_filter: String,
}

pub struct UntreatedVideoDataInner {
    videos: Vec<UntreatedVideo>,
    notify: notify::SourceNotify,
    event_tx: tokio::sync::mpsc::Sender<UntreatedVideoEvent>,
    dispose_tx: broadcast::Sender<()>,
    pub text_filter: String,
}

#[derive(Clone)]
pub struct UntreatedVideoData1 {
    inner: Arc<RwLock<UntreatedVideoDataInner>>,
}


pub enum UntreatedVideoEvent{
    InsertOrUpdate(Vec<Metadata>),
    Remove(Vec<PathBuf>),
}

impl UntreatedVideoEvent {
   
}

impl UntreatedVideoData1 {
    pub async fn new() -> anyhow::Result<Self> {
        let (dispose_tx, _) = broadcast::channel(16);
        let (return_tx, return_rx) = mpsc::channel(1);
        let (event_tx, event_rx) = mpsc::unbounded_channel();

        let videos = crate::model::UntreatedVideo::query_all().await?;
        let sources = Source::query_all().await?;
        let notify = notify::SourceNotify::new(&sources, event_tx)?;

        let inner = UntreatedVideoData1 {
            inner: Arc::new(RwLock::new(UntreatedVideoDataInner {
                videos,
                notify: notify.clone(),
                text_filter: "".to_string(),
                event_tx: return_tx.clone(),
                dispose_tx: dispose_tx.clone(),
            })),
        };

        inner.event_start(return_rx);
        notify.listen(return_tx, event_rx, dispose_tx.clone());

        Ok(inner)
    }

    fn event_start(&self, mut event_rx: tokio::sync::mpsc::Receiver<UntreatedVideoEvent>) {
        let self_ = self.clone();
        tokio::spawn(async move {
            let event = async {
                while let Some(event) = event_rx.recv().await {
                    match event {
                        UntreatedVideoEvent::InsertOrUpdate(_) => {}
                        UntreatedVideoEvent::Remove(_) => {}
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
}

impl UntreatedVideoData {
    pub async fn new() -> anyhow::Result<Self> {
        Ok(Self {
            videos: crate::model::UntreatedVideo::query_all().await?,
            text_filter: "".to_string(),
        })
    }

    #[frb(sync, getter)]
    pub fn videos(&self) -> Vec<UntreatedVideo> {
        if self.text_filter != "" {
            self.videos
                .clone()
                .into_iter()
                .filter(|v| {
                    v.metadata
                        .filename
                        .to_lowercase()
                        .contains(&self.text_filter.to_ascii_lowercase())
                })
                .collect()
        } else {
            self.videos.clone()
        }
    }

    pub(super) fn add_videos(&mut self, videos: Vec<UntreatedVideo>) {
        self.videos.extend(videos);
        send_untreated_file_event();
    }

    pub(super) fn remove_videos(&mut self, videos: &Vec<u32>) {
        self.videos.retain(|v| !videos.contains(&v.id));
        send_untreated_file_event();
    }

    pub(super) fn update_videos(&mut self, videos: Vec<UntreatedVideo>) {
        for video in videos {
            if let Some(v) = self.videos.iter_mut().find(|v| v.id.eq(&video.id)) {
                *v = video;
            }
        }
        send_untreated_file_event();
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
