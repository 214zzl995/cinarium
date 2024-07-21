pub use cinarium_runner::{PoolStatus, Task, TaskStatus};
use flutter_rust_bridge::{frb, DartFnFuture};

use crate::task::{PoolData, TaskMetadata};

use super::ListenerHandle;

#[allow(dead_code)]
pub async fn init_pool() -> anyhow::Result<()> {
    let tasks = crate::model::get_tasks().await?;
    crate::task::crawler::init_crawler_templates().await?;
    crate::task::get_task_manager().init_tasks(tasks);
    Ok(())
}

#[allow(dead_code)]
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

#[allow(dead_code)]
pub async fn delete_task(id: String) -> anyhow::Result<()> {
    crate::model::delete_task(&id).await?;
    crate::task::get_task_manager().remove_task(&id);
    Ok(())
}

#[allow(dead_code)]
pub async fn pause_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().pause().await
}

#[allow(dead_code)]
pub async fn resume_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().resume()
}

#[allow(dead_code)]
pub async fn force_pause_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().force_pause().await
}

#[allow(dead_code)]
pub async fn change_task_status(id: &str, status: TaskStatus) {
    crate::task::get_task_manager().change_task_status(id, status);
}

#[allow(dead_code)]
#[frb(sync)]
pub fn get_pool_data() -> anyhow::Result<PoolData> {
    Ok(PoolData::from(crate::task::get_task_manager()))
}

#[allow(dead_code)]
pub async fn listener_task_status_change(
    dart_callback: impl Fn(String, TaskStatus) -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    crate::task::listener_task_status_change(dart_callback)
}

#[allow(dead_code)]
pub async fn listener_pool_status_change(
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
