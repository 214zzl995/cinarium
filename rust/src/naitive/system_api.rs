use crate::{
    app::{self, get_cinarium_config, CinariumConfig, HttpConfig, TaskConfig},
    log,
};

pub fn init_app_log() -> anyhow::Result<()> {
    log::register_log()?;
    Ok(())
}

pub async fn run_web_api() -> anyhow::Result<()> {
    crate::api::run_web_api().await?;
    Ok(())
}

pub fn stop_web_api() -> anyhow::Result<()> {
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async { crate::api::stop_web_api().await })
}

pub fn get_hfs_status() -> anyhow::Result<bool> {
    crate::api::web_api_status()
}

pub fn get_local_ip() -> anyhow::Result<String> {
    let port = get_cinarium_config().http.port;
    let local = local_ipaddress::get().ok_or_else(|| anyhow::anyhow!("获取ip出错"))?;
    Ok(format!("http://{}:{}", local, port))
}

pub fn get_task_pool_conf() -> anyhow::Result<TaskConfig> {
    Ok(get_cinarium_config().task)
}

pub fn get_hfs_conf() -> anyhow::Result<HttpConfig> {
    Ok(get_cinarium_config().http)
}

pub async fn change_hfs_conf(conf: HttpConfig) -> anyhow::Result<CinariumConfig> {
    app::update_http_config(&conf).await
}

pub async fn change_task_pool_conf(conf: TaskConfig) -> anyhow::Result<CinariumConfig> {
    app::update_task_config(&conf).await
}

pub async fn change_tidy_folder() -> anyhow::Result<CinariumConfig> {
    let tidy_folder = get_cinarium_config().task.tidy_folder;
    let folder = rfd::AsyncFileDialog::new()
        .set_directory(tidy_folder)
        .pick_folder()
        .await;

    let mut task_conf = get_cinarium_config();

    match folder {
        Some(folder) => {
            let folder = folder.path().to_path_buf();

            task_conf.task.tidy_folder = folder;
            Ok(app::update_task_config(&task_conf.task).await?)
        }
        None => Ok(task_conf),
    }
}

pub fn open_in_explorer(path: String) -> anyhow::Result<()> {
    open::that(path)?;
    Ok(())
}

pub fn open_in_default_software(path: String) -> anyhow::Result<()> {
    opener::open(std::path::Path::new(&path))?;

    Ok(())
}
