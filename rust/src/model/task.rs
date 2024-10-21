use cinarium_crawler::Template;
use cinarium_runner::{Task, TaskStatus};

use crate::task::{crawler::CrawlerTemplate, TaskMetadata};

use super::{get_pool, VideoDataInterim};

pub async fn get_tasks() -> anyhow::Result<Vec<(String, Task<TaskMetadata>)>> {
    let pool = get_pool().await;
    let tasks = sqlx::query!(
        r#"
           select a.id     as "id!: String", COALESCE(c.name, COALESCE(crawl_name, filename)) as "name!: String",
                  a.status as "status!: u8", COALESCE(MAX(b.msg), '') as msg, a.video_id as "video_id!: u32"
           from task a
                inner join task_msg b on b.task_id = a.id
                inner join video c on a.video_id = c.id
            group by a.id, a.status, c.name, c.crawl_name, c.filename, a.video_id
            having MAX(b.msg) is not null
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

impl CrawlerTemplate {
    pub async fn get_crawler_templates() -> anyhow::Result<Vec<Self>> {
        let db_template = sqlx::query!(
            r#"
                select id as "id!: u32", base_url as "base_url!: String",search_url as "search_url!: String", json_raw as "json_raw!: String", priority as "priority!: u8", enabled as "enabled!: bool"
                from crawl_template
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        let templates: Vec<CrawlerTemplate> = db_template
            .into_iter()
            .map(|template| {
                let id = template.id;
                let base_url = template.base_url;
                let json_raw = template.json_raw;
                let priority = template.priority;
                let enabled = template.enabled;
                let search_url = template.search_url;

                let template = CrawlerTemplate {
                    id,
                    base_url,
                    search_url,
                    json_raw: json_raw.clone(),
                    template: Template::<VideoDataInterim>::from_json(&json_raw).unwrap(),
                    priority,
                    enabled,
                };

                template
            })
            .collect();

        Ok(templates)
    }

    #[allow(dead_code)]
    pub async fn insert1(&self) -> anyhow::Result<()> {
        let pool = get_pool().await;
        sqlx::query!(
            r#"
                insert into crawl_template (id, base_url, json_raw, priority, enabled)
                values ($1, $2, $3, $4, true)
            "#,
            self.id,
            self.base_url,
            self.json_raw,
            self.priority
        )
        .execute(pool)
        .await?;
        Ok(())
    }

    pub async fn insert(raw: &str, base_url: &str, search_url: &str) -> anyhow::Result<(u32, u8)> {
        let pool = get_pool().await;
        let priority = sqlx::query!(
            r#"
                select max(priority) as "priority!: u8"
                from crawl_template
            "#
        )
        .fetch_one(pool)
        .await?
        .priority
            + 1;

        let id = sqlx::query!(
            r#"
                insert into crawl_template (base_url, search_url, json_raw, priority, enabled)
                values ($1, $2, $3, $4, true)
                returning id as "id!: u32"
            "#,
            base_url,
            search_url,
            raw,
            priority
        )
        .fetch_one(pool)
        .await?
        .id;

        Ok((id, priority))
    }

    pub async fn update_priority(prioritys: &Vec<(u32, u8)>) -> anyhow::Result<()> {
        let mut tx = get_pool().await.begin().await?;
        for (id, priority) in prioritys {
            let id = id.clone() as i64;
            let priority = priority.clone() as i64;
            sqlx::query!(
                r#"
                    update crawl_template
                    set priority = $1
                    where id = $2
                "#,
                priority,
                id
            )
            .execute(&mut *tx)
            .await?;
        }
        tx.commit().await?;

        Ok(())
    }

    pub async fn switch_enabled(id: &u32) -> anyhow::Result<()> {
        let pool = get_pool().await;
        sqlx::query!(
            r#"
                update crawl_template
                set enabled = not enabled
                where id = $1
            "#,
            id
        )
        .execute(pool)
        .await?;
        Ok(())
    }
}
