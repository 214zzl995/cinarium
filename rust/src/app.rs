use parking_lot::Mutex;
use serde::{Deserialize, Serialize};

use std::{
    env,
    path::{Path, PathBuf},
};

static CINARIUM_CONFIG: tokio::sync::OnceCell<Mutex<CinariumConfig>> =
    tokio::sync::OnceCell::const_new();

#[derive(Deserialize, Serialize, Clone, Default, Debug)]
pub struct CinariumConfig {
    #[serde(skip)]
    config_file: PathBuf,
    pub http: HttpConfig,
    pub task: TaskConfig,
}

#[derive(Deserialize, Serialize, Clone, Debug)]
pub struct HttpConfig {
    pub port: u16,
}

#[derive(Deserialize, Serialize, Clone, Debug)]
pub struct TaskConfig {
    pub thread: usize,
    pub tidy_folder: PathBuf,
}

/// Initialization error software exit
pub async fn init_cinarium_config() -> anyhow::Result<()> {
    let config = CinariumConfig::new().await?;
    CINARIUM_CONFIG
        .set(Mutex::new(config))
        .map_err(|_| anyhow::anyhow!("set config error"))?;
    Ok(())
}

pub fn get_cinarium_config() -> CinariumConfig {
    if !CINARIUM_CONFIG.initialized() {
        panic!("config not initialized");
    }
    CINARIUM_CONFIG.get().unwrap().lock().clone()
}

pub async fn update_http_config(http: &HttpConfig) -> anyhow::Result<CinariumConfig> {
    let config = {
        let mut config = CINARIUM_CONFIG.get().unwrap().lock();
        config.http = http.clone();
        config.clone()
    };

    config.update_file().await?;
    Ok(config.clone())
}

pub async fn update_task_config(task: &TaskConfig) -> anyhow::Result<CinariumConfig> {
    let config = {
        let mut config = CINARIUM_CONFIG.get().unwrap().lock();
        config.task = task.clone();
        config.clone()
    };

    config.update_file().await?;
    Ok(config.clone())
}

impl CinariumConfig {
    async fn new() -> anyhow::Result<Self> {
        let config_file = match env::var("CINARIUM_CONFIG") {
            Ok(path) => PathBuf::from(path),
            Err(_) => dirs::config_dir()
                .unwrap()
                .join("cinarium")
                .join("config.toml"),
        };

        if !config_file.exists() {
            Self::create_new_config(&config_file).await
        } else {
            Self::from_file(&config_file).await
        }
    }

    async fn from_file(config_file: &Path) -> anyhow::Result<Self> {
        let config_str = tokio::fs::read_to_string(config_file).await?;
        let mut config: CinariumConfig = toml_edit::de::from_str(&config_str)?;

        config.config_file = config_file.to_path_buf();
        config.http.port = crate::get_web_api_port().unwrap_or(config.http.port);
        Ok(config)
    }

    async fn create_new_config(config_file: &Path) -> anyhow::Result<Self> {
        let config = CinariumConfig {
            config_file: config_file.to_path_buf(),
            http: HttpConfig::default(),
            task: TaskConfig::default(),
        };
        config.update_file().await?;

        Ok(config)
    }

    async fn update_file(&self) -> anyhow::Result<()> {
        let config_str = toml_edit::ser::to_string_pretty(self).unwrap();
        tokio::fs::write(&self.config_file, config_str).await?;
        Ok(())
    }
}

impl Default for TaskConfig {
    fn default() -> Self {
        TaskConfig {
            thread: 1,
            tidy_folder: dirs::video_dir().unwrap().join("Cinarium"),
        }
    }
}
