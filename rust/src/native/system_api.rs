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
pub async fn update_task_thread(thread: &u8) -> anyhow::Result<()> {
    let mut task_conf = get_cinarium_config().task;
    task_conf.thread = thread.clone();
    app::update_task_config(&task_conf).await
}

#[allow(dead_code)]
pub async fn update_task_tidy_folder(folder: String) -> anyhow::Result<()> {
    let folder = PathBuf::from(&folder);
    let mut task_conf = get_cinarium_config().task;
    task_conf.tidy_folder = folder;
    app::update_task_config(&task_conf).await
}

#[allow(dead_code)]
pub async fn add_source_notify_path(path: String) -> anyhow::Result<()> {
    let folder = PathBuf::from(&path);

    let paths = crate::notify::get_source_notify_paths()?;
    for path in paths {
        if path.eq(&folder) {
            return Ok(());
        }

        if folder.starts_with(&path) {
            return Ok(());
        }

        if path.starts_with(&folder) {
            crate::notify::unwatch_source(&path).await?;
        }
    }

    crate::notify::watch_source(&folder).await?;

    Ok(())
}

#[allow(dead_code)]
pub fn open_in_explorer(path: PathBuf) -> anyhow::Result<()> {
    open::that(path)?;
    Ok(())
}

#[allow(dead_code)]
pub fn open_in_explorer_by_string(path: String) -> anyhow::Result<()> {
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
pub fn get_source_notify_paths() -> anyhow::Result<Vec<String>> {
    let paths = crate::notify::get_source_notify_paths()?
        .into_iter()
        .map(|s| s.to_string_lossy().to_string())
        .collect();

    Ok(paths)
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

#[allow(dead_code)]
pub async fn listener_scan_storage(
    dart_callback: impl Fn(bool) -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    crate::notify::listener_scan_storage(dart_callback)
}

#[allow(dead_code)]
#[frb(sync)]
pub fn get_scan_storage_status() -> bool {
    crate::notify::get_scan_storage_status()
}

impl TaskConfig {
    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn tidy_folder(&self) -> String {
        self.tidy_folder.to_string_lossy().to_string()
    }

    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn thread(&self) -> u8 {
        self.thread
    }
}
