use cinarium_runner::{Task, TaskStatus};

use crate::task::{PoolData, TaskMetadata};

pub async fn pool_init() -> anyhow::Result<()> {
    let tasks = crate::model::get_tasks().await?;
    crate::task::get_task_manager().init_tasks(tasks);
    Ok(())
}

pub async fn add_task(task: TaskMetadata) -> anyhow::Result<String> {
    let id = task.insert().await?;
    let task = Task::new(task.clone(), TaskStatus::Wait, String::new());
    crate::task::get_task_manager().add_task(&id, task)
}

pub async fn delete_task(id: String) -> anyhow::Result<()> {
    crate::model::delete_task(&id).await?;
    crate::task::get_task_manager().remove_task(&id);
    Ok(())
}

pub async fn pause_task_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().pause().await
}

pub async fn resume_task_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().resume()
}

pub async fn force_pause_task_pool() -> anyhow::Result<()> {
    crate::task::get_task_manager().force_pause().await
}

pub async fn change_task_status(id: &str, status: TaskStatus) {
    crate::task::get_task_manager().change_task_status(id, status);
}

pub async fn get_task_pool() -> anyhow::Result<PoolData<TaskMetadata>> {
    Ok(PoolData::from(crate::task::get_task_manager()))
}
