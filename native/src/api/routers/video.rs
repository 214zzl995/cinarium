use super::super::Result;
use axum::extract::{Path, Query};

use crate::{
    api::res::{PageParams, Res},
    model::{DetailVideo, HomeVideo},
};

#[allow(clippy::unused_async)]
pub(super) async fn get_videos_all() -> Result<Res<Vec<HomeVideo>>> {
    let videos = HomeVideo::query_all().await?;
    Ok(Res::with_data(videos))
}

#[allow(clippy::unused_async)]
pub(super) async fn get_videos_paging(
    Query(page_params): Query<PageParams>,
) -> Result<Res<Vec<HomeVideo>>> {
    let videos = HomeVideo::query_paging(&page_params.page_size, &page_params.page_num).await?;
    Ok(Res::with_data(videos))
}

#[allow(clippy::unused_async)]
pub(super) async fn get_video_detail(Path(id): Path<u32>) -> Result<Res<DetailVideo>> {
    let video = DetailVideo::query_by_id(&id).await?;
    Ok(Res::with_data(video))
}
