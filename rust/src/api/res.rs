use std::fmt::Debug;

use axum::{
    body::{self},
    http::{header, HeaderValue, StatusCode},
    response::{IntoResponse, Response},
};
use serde::{Deserialize, Serialize};
#[derive(Debug, Serialize)]
pub struct ListData<T>
where
    T: Serialize + Debug + Copy,
{
    pub total: usize,
    pub total_pages: usize,
    pub page_num: usize,
    pub list: Vec<T>,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct PageParams {
    #[serde(default)]
    pub page_num: usize,
    #[serde(default)]
    pub page_size: usize,
}


#[derive(Debug, Serialize, Default)]
pub struct Res<T>
where
    T: Serialize,
{
    pub code: i32,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<T>,
    pub msg: String,
}

impl<T: Serialize> Res<T> {
    pub fn with_data(data: T) -> Self {
        Self {
            code: 200,
            data: Some(data),
            msg: "success".to_string(),
        }
    }
    #[allow(dead_code)]
    pub fn with_data_msg(data: T, msg: &str) -> Self {
        Self {
            code: 200,
            data: Some(data),
            msg: msg.to_string(),
        }
    }
}

impl Res<()> {
    pub fn with_msg(msg: &str) -> Self {
        Self {
            code: 200,
            data: None,
            msg: msg.to_string(),
        }
    }
    pub fn with_err(err: &str) -> Self {
        Self {
            code: 500,
            data: None,
            msg: err.to_string(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct ResJsonString(pub String);

#[allow(unconditional_recursion)]
impl<T> IntoResponse for Res<T>
where
    T: Serialize + Send + Sync + Debug + 'static,
{
    fn into_response(self) -> Response {
        let data = Self {
            code: self.code,
            data: self.data,
            msg: self.msg,
        };

        let json_string = match serde_json::to_string(&data) {
            Ok(v) => v,
            Err(e) => {
                return Response::builder()
                    .status(StatusCode::INTERNAL_SERVER_ERROR)
                    .header(
                        header::CONTENT_TYPE,
                        HeaderValue::from_static(mime::TEXT_PLAIN_UTF_8.as_ref()),
                    )
                    .body(body::Body::from(e.to_string()))
                    .unwrap();
            }
        };
        let res_json_string = ResJsonString(json_string.clone());
        let mut response = json_string.into_response();
        response.extensions_mut().insert(res_json_string);
        response
    }
}
