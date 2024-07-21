use std::sync::OnceLock;

use chrono::{DateTime, Local};
use cinarium_runner::TaskStatus;
use cinarium_runner::{PoolStatus, RunnerManger};
use flutter_rust_bridge::{frb, DartFnFuture};
use serde::{Deserialize, Serialize};
use tokio::sync::watch::Sender;

pub mod crawler;

use crate::{
    app::get_cinarium_config, model::VideoDataInterim, native::ListenerHandle,
};

static TASK_MANAGER: OnceLock<RunnerManger<TaskMetadata>> = OnceLock::new();
static LISTENER: OnceLock<Sender<(String, TaskStatus)>> = OnceLock::new();

#[derive(Eq, PartialEq, Clone, Debug, Hash, Deserialize, Serialize)]
pub struct TaskMetadata {
    pub name: String,
    pub video_id: u32,
}
#[derive(Clone, Debug)]
pub struct TaskOperationalData {
    pub status: TaskStatus,
    pub schedule: u8,
    pub last_log: String,
    pub create_at: DateTime<Local>,
    pub metadata: TaskMetadata,
}

#[derive(Clone, Debug)]
#[frb(non_opaque)]
pub struct PoolData {
    pub status: PoolStatus,
    pub tasks: Vec<(String, TaskOperationalData)>,
}

pub fn get_task_manager() -> RunnerManger<TaskMetadata> {
    TASK_MANAGER
        .get_or_init(|| {
            let thread = get_cinarium_config().task.thread;
            RunnerManger::new(
                thread,
                true,
                |data| async move { VideoDataInterim::run(&data).await },
                |task_id: String, status: TaskStatus| {
                    tracing::info!("Task: {} -- Status: {:?}", task_id, status);

                    let change_task_id = task_id.clone();
                    let change_status = status.clone();

                    tokio::spawn(crate::model::change_task_status(
                        change_task_id,
                        change_status,
                    ));

                    let sender = LISTENER
                        .get_or_init(|| {
                            let (tx, _) =
                                tokio::sync::watch::channel((task_id.clone(), status.clone()));
                            tx
                        });

                        if sender.receiver_count() > 0 {
                            sender.send((task_id, status)).unwrap();
                        }
                },
            )
        })
        .clone()
}

pub fn listener_task_status_change(
    dart_callback: impl Fn(String, cinarium_runner::TaskStatus) -> DartFnFuture<()>
        + Send
        + Sync
        + 'static,
) -> ListenerHandle {
    let (handle_tx, handle_rx) = tokio::sync::oneshot::channel::<()>();
    tokio::spawn(async move {
        let mut rx = LISTENER
            .get_or_init(|| {
                let (tx, _) = tokio::sync::watch::channel((
                    "".to_string(),
                    cinarium_runner::TaskStatus::Wait,
                ));
                tx
            })
            .subscribe();

        let listener = async {
            while let Ok(()) = rx.changed().await {
                let (task_id, status) = rx.borrow_and_update().clone();
                dart_callback(task_id, status).await;
            }
        };

        tokio::select! {
            _ = handle_rx => {},
            _ = listener => {},
        };
    });
    ListenerHandle::new(handle_tx)
}

pub fn listener_pool_status_change(
    dart_callback: impl Fn(PoolStatus) -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    let (handle_tx, handle_rx) = tokio::sync::oneshot::channel::<()>();
    tokio::spawn(async move {
        let mut rx = get_task_manager().watch_pool_status();

        let listener = async {
            while let Ok(()) = rx.changed().await {
                let status = rx.borrow_and_update().clone();
                dart_callback(status).await;
            }
        };

        tokio::select! {
            _ = handle_rx => {},
            _ = listener => {},
        };
    });
    ListenerHandle::new(handle_tx)
}

impl From<RunnerManger<TaskMetadata>> for PoolData {
    fn from(runner: RunnerManger<TaskMetadata>) -> Self {
        let tasks = runner
            .get_all_task()
            .into_iter()
            .map(|(task_id, task)| {
                let status = task.status.clone();
                let schedule = task.schedule;
                let last_log = task.last_log.clone();
                let create_at = task.create_at.clone();
                let metadata = task.metadata.clone();
                (
                    task_id,
                    TaskOperationalData {
                        status,
                        schedule,
                        last_log,
                        create_at,
                        metadata,
                    },
                )
            })
            .collect();

        PoolData {
            status: runner.get_pool_status(),
            tasks,
        }
    }
}
