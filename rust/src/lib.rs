mod frb_generated;

/* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
use app::HttpConfig;

extern crate anyhow;
pub use cinarium_runner::{PoolStatus, Task, TaskStatus};
pub use model::video::VideoDataInterim;
pub use std::path::PathBuf;
pub use task::crawler::Template;
pub use tokio::sync::oneshot::Sender;
pub use task::TaskMetadata;

mod api;
mod app;
mod log;
mod model;
mod native;
mod notify;
mod task;

impl Default for HttpConfig {
    fn default() -> Self {
        HttpConfig { port: 3225 }
    }
}

pub fn get_web_api_port() -> Option<u16> {
    None
}
