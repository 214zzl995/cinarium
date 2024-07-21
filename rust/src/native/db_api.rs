use crate::model::{HomeVideo, UntreatedVideo};

#[allow(dead_code)]
pub async fn init_db() -> anyhow::Result<()> {
    crate::model::init_db().await
}

#[allow(dead_code)]
pub async fn get_home_videos() -> anyhow::Result<Vec<HomeVideo>> {
    Ok(HomeVideo::query_all().await?)
}

#[allow(dead_code)]
pub async fn get_task_videos() -> anyhow::Result<Vec<UntreatedVideo>> {
    UntreatedVideo::query_all().await
}

#[allow(dead_code)]
pub async fn switch_videos_hidden(ids: Vec<u32>) -> anyhow::Result<()> {
    UntreatedVideo::switch_videos_hidden(ids).await
}

#[allow(dead_code)]
pub async fn update_crawl_name(id: u32, crawl_name: String) -> anyhow::Result<()> {
    UntreatedVideo::update_crawl_name_with_id(&id, &crawl_name).await
}

