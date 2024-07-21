use axum::response::IntoResponse;
use thiserror::Error;

use super::res::Res;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("database : `{0}`")]
    DataBase(#[from] sqlx::Error),
    #[error("other : `{0}`")]
    #[allow(dead_code)]
    Other(String),
}

pub type Result<T> = std::result::Result<T, ApiError>;

impl IntoResponse for ApiError {
    fn into_response(self) -> axum::response::Response {
        Res::with_err(&self.to_string()).into_response()
    }
}
