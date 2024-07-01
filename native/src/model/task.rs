use cinarium_runner::{Task, TaskStatus};

use crate::task::TaskMetadata;

use super::get_pool;

pub async fn get_tasks() -> anyhow::Result<Vec<(String, Task<TaskMetadata>)>> {
    let pool = get_pool().await;
    let tasks = sqlx::query!(
        r#"
           select a.id as "id!: String", coalesce(c.name,coalesce(crawl_name,filename)) as "name!: String", status as "status!: u8", coalesce(max(b.msg),'') as msg, video_id as "video_id!:u32"
           from task a,
                task_msg b,
                video c
           where b.task_id = a.id
             and a.video_id = c.id
        "#,
    )
    .fetch_all(pool)
    .await?;

    let tasks: Vec<(String, Task<TaskMetadata>)> = tasks
        .into_iter()
        .map(|task| {
            let id = task.id;
            let name = task.name;
            let status = TaskStatus::from(task.status);
            let msg = task.msg;
            let video_id = task.video_id;

            let task = Task::new(TaskMetadata { name, video_id }, status, msg);

            (id, task)
        })
        .collect();

    Ok(tasks)
}

pub async fn change_task_status(id: String, status: TaskStatus) -> anyhow::Result<()> {
    let pool = get_pool().await;
    let status = status as u8;
    sqlx::query!(
        r#"
            update task
            set status = $1
            where id = $2
        "#,
        status,
        id
    )
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn delete_task(id: &str) -> anyhow::Result<()> {
    let pool = get_pool().await;
    sqlx::query!(
        r#"
            delete from task
            where id = $1
        "#,
        id
    )
    .execute(pool)
    .await?;
    Ok(())
}
impl TaskMetadata {
    pub async fn insert(&self) -> anyhow::Result<String> {
        let pool = get_pool().await;
        let id = uuid::Uuid::new_v4().to_string();

        let id = sqlx::query!(
            r#"
              insert into task (id, video_id)
              values ($1, $2)
              returning id as "id!: String"
            "#,
            id,
            self.video_id
        )
        .fetch_one(pool)
        .await?
        .id;

        Ok(id)
    }
}
