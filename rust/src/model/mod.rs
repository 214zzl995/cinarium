use sqlx::{migrate::Migrator, SqlitePool};
use tokio::sync::{Mutex, OnceCell};

pub(crate) mod source;
mod task;
pub(crate) mod video;

pub use source::Source;
pub use task::{change_task_status, delete_task, get_tasks};
pub use video::{DetailVideo, HomeVideo, Metadata, UntreatedVideo, VideoDataInterim};

static POOL: OnceCell<SqlitePool> = OnceCell::const_new();
static SOURCE_LOCK: OnceCell<Mutex<()>> = OnceCell::const_new();

pub(crate) async fn get_pool() -> &'static SqlitePool {
    if !std::path::Path::new("database.db").exists() {
        std::fs::File::create("database.db").unwrap();
    }

    POOL.get_or_init(|| async { SqlitePool::connect("sqlite:database.db").await.unwrap() })
        .await
}

pub async fn init_db() -> anyhow::Result<()> {
    let migrate: Migrator = sqlx::migrate!();
    migrate.run(get_pool().await).await?;

    let _ = SOURCE_LOCK.get_or_init(|| async { Mutex::new(()) }).await;
    Ok(())
}
