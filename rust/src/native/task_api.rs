pub use cinarium_runner::{PoolStatus, Task, TaskStatus};
use flutter_rust_bridge::{frb, DartFnFuture};

use crate::task::{PoolData, TaskMetadata};

use super::ListenerHandle;

pub async fn pool_init() -> anyhow::Result<()> {
    let tasks = crate::model::get_tasks().await?;
    crate::task::get_task_manager().init_tasks(tasks);
    Ok(())
}

pub async fn insertion_of_tasks(tasks: Vec<TaskMetadata>) -> anyhow::Result<Vec<String>> {
    let mut ids = Vec::new();

    for t in tasks.iter() {
        let id = t.insert().await?;
        let task = Task::new(t.clone(), TaskStatus::Wait, String::new());
        crate::task::get_task_manager().add_task(&id, &task)?;
        ids.push(id);
    }
    Ok(ids)
}

pub async fn delete_task(id: String) -> anyhow::Result<()> {
    crate::model::delete_task(&id).await?;
    crate::task::get_task_manager().remove_task(&id);
    Ok(())
}

pub async fn pause_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().pause().await
}

pub async fn resume_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().resume()
}

pub async fn force_pause_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().force_pause().await
}

pub async fn change_task_status(id: &str, status: TaskStatus) {
    crate::task::get_task_manager().change_task_status(id, status);
}

#[frb(sync)]
pub fn get_pool_data() -> anyhow::Result<PoolData> {
    Ok(PoolData::from(crate::task::get_task_manager()))
}

#[frb(sync)]
pub fn listener_task_status_change(
    dart_callback: impl Fn(String, TaskStatus) -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    crate::task::listener_task_status_change(dart_callback)
}

#[frb(sync)]
pub fn listener_pool_status_change(
    dart_callback: impl Fn(PoolStatus) -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    crate::task::listener_pool_status_change(dart_callback)
}

#[frb(mirror(TaskStatus))]
#[repr(u8)]
pub enum _TaskStatus {
    Wait,
    Running,
    Fail,
    Success,
    Pause,
}

#[frb(mirror(PoolStatus))]
#[repr(u8)]
pub enum _PoolStatus {
    Running,
    Pause,
    PauseLoading,
}
