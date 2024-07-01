use sqlx::{migrate::Migrator, SqlitePool};
use tokio::sync::OnceCell;

mod source;
mod task;
mod video;

pub use task::{change_task_status, delete_task, get_tasks};
pub use video::{DetailVideo, HomeVideo, Metadata, TaskVideo, VideoDataInterim};
pub use source::Source;

static POOL: OnceCell<SqlitePool> = OnceCell::const_new();

pub(crate) async fn get_pool() -> &'static SqlitePool {
    POOL.get_or_init(|| async { SqlitePool::connect("sqlite:database.db").await.unwrap() })
        .await
}

pub async fn db_init() -> anyhow::Result<()> {
    let migrate: Migrator = sqlx::migrate!();
    migrate.run(get_pool().await).await?;
    Ok(())
}
