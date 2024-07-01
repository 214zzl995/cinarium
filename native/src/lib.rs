use app::HttpConfig;

extern crate anyhow;

mod api;
mod app;
mod log;
mod model;
mod naitive;
mod notify;
mod task;

impl Default for HttpConfig {
    fn default() -> Self {
        HttpConfig { port: 3225 }
    }
}

pub fn get_web_api_port() -> Option<u16> {
    None
}
