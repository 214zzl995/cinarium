use serde::{Deserialize, Serialize};
use std::path::PathBuf;

use super::get_pool;

#[derive(Serialize, Deserialize, Debug,Clone)]
pub struct Source {
    pub id: u32,
    pub path: PathBuf,
}

impl Source {
    pub async fn insert(path: PathBuf) -> anyhow::Result<u32> {
        let path = path.to_str().unwrap();
        let id = sqlx::query!(
            r#"insert into source (path) values (?1) returning id as "id!:u32""#,
            path
        )
        .fetch_one(get_pool().await)
        .await?
        .id;

        Ok(id)
    }

    pub async fn delete(&self) -> anyhow::Result<()> {
        sqlx::query!("delete from source where id = ?1", self.id)
            .execute(get_pool().await)
            .await?;
        Ok(())
    }

    pub async fn query_all() -> anyhow::Result<Vec<Source>> {
        let sources = sqlx::query_as!(
            Source,
            r#"select id as "id!:u32",path as "path!" from source"#
        )
        .fetch_all(get_pool().await)
        .await?;
        Ok(sources)
    }
}
