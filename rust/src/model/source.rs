use serde::{Deserialize, Serialize};
use std::path::PathBuf;

use super::get_pool;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Source {
    pub id: u32,
    pub path: PathBuf,
}

impl Source {
    #[allow(dead_code)]
    pub async fn insert(path: &PathBuf) -> anyhow::Result<Self> {
        let path_str = path.to_str().unwrap();
        let id = sqlx::query!(
            r#"insert into source (path) values (?1) returning id as "id!:u32""#,
            path_str
        )
        .fetch_one(get_pool().await)
        .await?
        .id;

        Ok(Self {
            id,
            path: path.clone(),
        })
    }

    #[allow(dead_code)]
    pub async fn delete(&self) -> anyhow::Result<()> {
        let _ = super::SOURCE_LOCK.get().unwrap().lock().await;
        sqlx::query!("delete from source where id = $1", self.id)
            .execute(get_pool().await)
            .await?;
        Ok(())
    }

    #[allow(dead_code)]
    pub async fn query_all() -> anyhow::Result<Vec<Source>> {
        let sources = sqlx::query_as!(
            Source,
            r#"select id as "id!:u32",path as "path!" from source"#
        )
        .fetch_all(get_pool().await)
        .await?;
        Ok(sources)
    }

    pub async fn query_by_path(path: &PathBuf) -> anyhow::Result<Source> {
        let path_str = path.to_str().unwrap();
        let source = sqlx::query_as!(
            Source,
            r#"select id as "id!:u32",path as "path!" from source where path = ?1"#,
            path_str
        )
        .fetch_one(get_pool().await)
        .await?;

        Ok(source)
    }
}
