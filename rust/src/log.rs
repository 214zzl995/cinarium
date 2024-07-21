use std::{fs::create_dir_all, path::PathBuf, sync::{atomic::{AtomicBool, Ordering}, OnceLock}};

use tracing_appender::{
    non_blocking::WorkerGuard,
    rolling::{RollingFileAppender, Rotation},
};
use tracing_subscriber::{
    filter, prelude::__tracing_subscriber_SubscriberExt, util::SubscriberInitExt, Layer,
};

pub struct HfsLayer();

impl<S> Layer<S> for HfsLayer
where
    S: tracing::Subscriber,
{
    fn on_event(
        &self,
        event: &tracing::Event<'_>,
        _ctx: tracing_subscriber::layer::Context<'_, S>,
    ) {
        let metadata = event.metadata();
        let _level = metadata.level();
        let _target = metadata.target();

        let _fields = event.metadata().fields();
    }
}

static LOG_REGISTERED: AtomicBool = AtomicBool::new(false);
static LOG_GUARD: OnceLock<WorkerGuard> = OnceLock::new();

pub fn register_log() -> anyhow::Result<()> {
    if LOG_REGISTERED.load(Ordering::SeqCst) {
        return Ok(());
    }

    let log_directory = if cfg!(debug_assertions) {
        PathBuf::from("./log")
    } else {
        dirs::cache_dir().unwrap().join("cinarium").join("log")
    };

    if !log_directory.exists() {
        create_dir_all(&log_directory)?;
    }

    let file_appender = RollingFileAppender::builder()
        .rotation(Rotation::DAILY)
        .filename_prefix("")
        .filename_suffix("log")
        .max_log_files(5)
        .build(log_directory)?;

    let (non_blocking, guard) = tracing_appender::non_blocking(file_appender);
    // Putting the logging daemon into OnceLock to guarantee the lifecycle
    LOG_GUARD.set(guard).unwrap();

    let log_level = if cfg!(debug_assertions) {
        filter::LevelFilter::INFO
    } else {
        filter::LevelFilter::INFO
    };

    let stdout_log = tracing_subscriber::fmt::layer()
        .with_thread_names(true)
        .with_target(false)
        .with_file(false)
        .with_line_number(false)
        .pretty()
        .with_filter(log_level);

    let file_log = tracing_subscriber::fmt::layer()
        .with_writer(non_blocking)
        .with_ansi(false)
        .with_file(true)
        .with_filter(filter::LevelFilter::INFO);

    let std_log = stdout_log.and_then(file_log);

    let web_api_log =
        HfsLayer().with_filter(filter::filter_fn(|metadata| metadata.target() == "web_api"));

    tracing_subscriber::registry()
        .with(std_log)
        .with(web_api_log)
        .init();

    LOG_REGISTERED.store(true, std::sync::atomic::Ordering::SeqCst);

    Ok(())
}
