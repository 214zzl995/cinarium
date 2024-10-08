use flutter_rust_bridge::frb;
use tokio::sync::oneshot;


pub mod system_api;
pub mod db_api;
pub mod task_api;
pub mod home_api;

pub struct ListenerHandle(#[allow(dead_code)] oneshot::Sender<()>);

impl ListenerHandle {
    #[frb(sync)]
    pub fn cancel(self) {
        self.0.send(()).unwrap();
    }

    #[frb(ignore)]
    pub fn new(sender: oneshot::Sender<()>) -> Self {
        Self(sender)
    }
}

