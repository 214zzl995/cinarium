use std::path::PathBuf;

use flutter_rust_bridge::{frb, DartFnFuture};

use crate::{
    app::{self, get_cinarium_config, HttpConfig, TaskConfig},
    log,
    task::crawler::CrawlerTemplate,
};

use super::ListenerHandle;

#[allow(dead_code)]
pub fn init_app_log() -> anyhow::Result<()> {
    log::register_log()?;
    Ok(())
}

#[allow(dead_code)]
pub async fn init_cinarium_config() -> anyhow::Result<()> {
    app::init_cinarium_config().await?;
    Ok(())
}

#[allow(dead_code)]
pub async fn init_source_notify() -> anyhow::Result<()> {
    crate::notify::init_source_notify().await?;
    Ok(())
}

#[allow(dead_code)]
pub async fn run_web_api() -> anyhow::Result<()> {
    crate::api::run_web_api().await?;
    Ok(())
}

#[allow(dead_code)]
pub async fn stop_web_api() -> anyhow::Result<()> {
    crate::api::stop_web_api().await
}

#[frb(sync)]
#[allow(dead_code)]
pub fn get_http_status() -> anyhow::Result<bool> {
    crate::api::web_api_status()
}

#[frb(sync)]
#[allow(dead_code)]
pub fn get_local_ip() -> anyhow::Result<String> {
    let port = get_cinarium_config().http.port;
    let local = local_ipaddress::get().ok_or_else(|| anyhow::anyhow!("获取ip出错"))?;
    Ok(format!("http://{}:{}", local, port))
}

#[allow(dead_code)]
pub fn get_task_conf() -> TaskConfig {
    get_cinarium_config().task
}

#[allow(dead_code)]
pub fn get_http_conf() -> HttpConfig {
    get_cinarium_config().http
}

#[allow(dead_code)]
pub async fn update_http_port(port: &u16) -> anyhow::Result<()> {
    let http_config = HttpConfig { port: port.clone() };
    app::update_http_config(&http_config).await
}

#[allow(dead_code)]
pub async fn update_task_thread(thread: &usize) -> anyhow::Result<()> {
    let mut task_conf = get_cinarium_config().task;
    task_conf.thread = thread.clone();
    app::update_task_config(&task_conf).await
}

#[allow(dead_code)]
pub async fn update_task_tidy_folder() -> anyhow::Result<()> {
    let tidy_folder = get_cinarium_config().task.tidy_folder;
    let folder = rfd::AsyncFileDialog::new()
        .set_directory(tidy_folder)
        .pick_folder()
        .await;

    let mut task_conf = get_cinarium_config().task;

    match folder {
        Some(folder) => {
            let folder = folder.path().to_path_buf();

            task_conf.tidy_folder = folder;
            app::update_task_config(&task_conf).await
        }
        None => Ok(()),
    }
}

#[allow(dead_code)]
pub fn open_in_explorer(path: PathBuf) -> anyhow::Result<()> {
    open::that(path)?;
    Ok(())
}

#[allow(dead_code)]
pub fn open_in_default_software(path: String) -> anyhow::Result<()> {
    opener::open(std::path::Path::new(&path))?;

    Ok(())
}

#[allow(dead_code)]
pub async fn change_crawler_templates_priority(prioritys: Vec<(u32, u8)>) -> anyhow::Result<()> {
    crate::task::crawler::change_crawler_templates_priority(prioritys).await
}

#[allow(dead_code)]
pub async fn switch_crawler_template_enabled(id: u32) -> anyhow::Result<()> {
    crate::task::crawler::switch_crawler_templates_enabled(id).await
}

#[allow(dead_code)]
#[frb(sync)]
pub fn get_crawler_templates() -> anyhow::Result<Vec<CrawlerTemplate>> {
    crate::task::crawler::get_crawler_templates()
}

#[allow(dead_code)]
#[frb(sync)]
pub fn path_buf_2_string(path: PathBuf) -> String {
    path.to_string_lossy().to_string()
}

#[allow(dead_code)]
#[frb(sync)]
pub fn string_2_path_buf(path: String) -> PathBuf {
    PathBuf::from(path)
}

#[allow(dead_code)]
pub async fn listener_http_status(
    dart_callback: impl Fn(bool) -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    crate::api::listener_http_status(dart_callback)
}

#[allow(dead_code)]
pub async fn listener_untreated_file(
    dart_callback: impl Fn() -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    crate::notify::listener_untreated_file(dart_callback)
}

impl TaskConfig {
    
    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn tidy_folder(&self) -> String {
        self.tidy_folder.to_string_lossy().to_string()
    }

    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn thread(&self) -> usize {
        self.thread
    }
}





