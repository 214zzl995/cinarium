use std::sync::OnceLock;

use cinarium_runner::{PoolStatus, RunnerManger, Task};
use serde::{Deserialize, Serialize};

mod crawler;

use crate::{app::get_cinarium_config, model::VideoDataInterim};

static TASK_MANAGER: OnceLock<RunnerManger<TaskMetadata>> = OnceLock::new();

pub fn get_task_manager() -> RunnerManger<TaskMetadata> {
    TASK_MANAGER
        .get_or_init(|| {
            let thread = get_cinarium_config().task.thread;
            RunnerManger::new(
                thread,
                true,
                |data| async move {
                    VideoDataInterim::run(&data).await
                },
                |task_id, status| {
                    tracing::info!("Task: {} -- Status: {:?}", task_id, status);
                    tokio::spawn(crate::model::change_task_status(task_id, status));
                },
            )
        })
        .clone()
}

#[derive(Eq, PartialEq, Clone, Debug, Hash, Deserialize, Serialize)]
pub struct TaskMetadata {
    pub name: String,
    pub video_id: u32,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct PoolData<T>
where
    T: Send + Sync + 'static + Clone,
{
    pub status: PoolStatus,
    pub tasks: Vec<(String, Task<T>)>,
}
impl<T> From<RunnerManger<T>> for PoolData<T>
where
    T: Send + Sync + 'static + Clone,
{
    fn from(runner: RunnerManger<T>) -> Self {
        let tasks = runner.get_all_task();

        PoolData {
            status: runner.get_pool_status(),
            tasks,
        }
    }
}
