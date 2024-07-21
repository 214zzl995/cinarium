use axum::{handler::HandlerWithoutStateExt, http::StatusCode, routing::get, Router};
use tower_http::services::ServeDir;

use crate::app::get_cinarium_config;

mod sys;
mod video;

use super::routers::index;
pub use sys::*;

pub fn api() -> Router {
    Router::new()
        .nest("/", index_api())
        .nest("/data", data_api())
        .nest("/assets", assets_api())
}

fn index_api() -> Router {
    Router::new().route("/", get(index))
}

fn assets_api() -> Router {
    let tidy_folder = get_cinarium_config().task.tidy_folder;
    let service = file_not_found.into_service();
    let serve_dir = ServeDir::new(tidy_folder).not_found_service(service);
    Router::new().fallback_service(serve_dir)
}

fn data_api() -> Router {
    Router::new()
        .route("/video", get(video::get_videos_all))
        .route("/video/paging", get(video::get_videos_paging))
        .route("/video/:id", get(video::get_video_detail))
}

#[allow(dead_code)]
pub async fn handler_404() -> (StatusCode, &'static str) {
    (StatusCode::NOT_FOUND, "nothing to see here")
}

#[allow(clippy::unused_async)]
pub async fn file_not_found() -> (StatusCode, &'static str) {
    (StatusCode::INTERNAL_SERVER_ERROR, "File not found...")
}
