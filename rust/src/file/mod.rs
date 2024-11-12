use std::sync::OnceLock;

use flutter_rust_bridge::{frb, DartFnFuture};
use parking_lot::RwLock;
use tokio::sync::{broadcast, oneshot, OnceCell};

use crate::{model::UntreatedVideo, native::ListenerHandle};

mod notify;

pub use notify::{
    get_scan_storage_status, get_source_notify_sources, init_source_notify, listener_scan_storage,
    unwatch_source, watch_source,
};

static UNTREATED_VIDEO_DATA: OnceCell<RwLock<UntreatedVideoData>> = OnceCell::const_new();
static UNTREATED_FILE_LISTENER: OnceLock<broadcast::Sender<()>> = OnceLock::new();

pub async fn untreated_video_data() -> anyhow::Result<UntreatedVideoData> {
    Ok(UNTREATED_VIDEO_DATA
        .get_or_try_init(|| async { anyhow::Ok(RwLock::new(UntreatedVideoData::new().await?)) })
        .await?
        .read()
        .clone())
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct UntreatedVideoData {
    videos: Vec<UntreatedVideo>,
    pub text_filter: String,
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
