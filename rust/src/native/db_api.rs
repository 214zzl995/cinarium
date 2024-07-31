use flutter_rust_bridge::frb;

use crate::model::{HomeVideo, Metadata, UntreatedVideo};

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

impl Metadata {
    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn get_path(&self) -> anyhow::Result<String> {
        Ok(self.path.to_string_lossy().to_string())
    }

    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn get_size(&self) -> anyhow::Result<u64> {
        Ok(self.size)
    }

    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn get_extension(&self) -> anyhow::Result<String> {
        Ok(self.extension.clone())
    }

    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn get_filename(&self) -> anyhow::Result<String> {
        Ok(self.filename.clone())
    }


}
