use crate::model::{HomeVideo, TaskVideo};

pub async fn get_home_video() -> anyhow::Result<Vec<HomeVideo>> {
    Ok(HomeVideo::query_all().await?)
}

pub async fn get_task_videos() -> anyhow::Result<Vec<TaskVideo>> {
    TaskVideo::query_all().await
}

pub async fn hidden_videos(id: Vec<u32>) -> anyhow::Result<()> {
    TaskVideo::hidden_videos(id).await
}

pub async fn update_crawl_name(id: u32, crawl_name: String) -> anyhow::Result<()> {
    TaskVideo::update_crawl_name_with_id(&id, &crawl_name).await
}
