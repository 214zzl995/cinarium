use crate::model::{HomeVideo, UntreatedVideo};

pub async fn get_home_videos() -> anyhow::Result<Vec<HomeVideo>> {
    Ok(HomeVideo::query_all().await?)
}

pub async fn get_task_videos() -> anyhow::Result<Vec<UntreatedVideo>> {
    UntreatedVideo::query_all().await
}

pub async fn switch_videos_hidden(ids: Vec<u32>) -> anyhow::Result<()> {
    UntreatedVideo::switch_videos_hidden(ids).await
}

pub async fn update_crawl_name(id: u32, crawl_name: String) -> anyhow::Result<()> {
    UntreatedVideo::update_crawl_name_with_id(&id, &crawl_name).await
}

