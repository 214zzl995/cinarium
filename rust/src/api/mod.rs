mod error;
mod res;
mod routers;

use crate::{app::get_cinarium_config, native::ListenerHandle};
use anyhow::Context;
use error::Result;
use flutter_rust_bridge::DartFnFuture;
use tower_http::trace::TraceLayer;

use std::{net::SocketAddr, sync::OnceLock};

use parking_lot::Mutex;
use tokio::sync::{mpsc, oneshot, watch};

static HANDLE: OnceLock<Mutex<Option<mpsc::Sender<()>>>> = OnceLock::new();
static LISTENER: OnceLock<watch::Sender<bool>> = OnceLock::new();

pub async fn run_web_api() -> anyhow::Result<()> {
    let addr = SocketAddr::from(([0, 0, 0, 0], get_cinarium_config().http.port));
    let listener = tokio::net::TcpListener::bind(addr).await?;
    tracing::info!("WebAPI instance listening on {}", addr);

    let listener_tx = LISTENER.get_or_init(|| {
        let (tx, _) = watch::channel(false);
        tx
    });

    if listener_tx.receiver_count() > 0 {
        listener_tx.send(true)?;
    }

    axum::serve(listener, routers::api().layer(TraceLayer::new_for_http()))
        .with_graceful_shutdown(shutdown_signal())
        .await?;

    Ok(())
}

pub fn listener_http_status(
    dart_callback: impl Fn(bool) -> DartFnFuture<()> + Send + Sync + 'static,
) -> ListenerHandle {
    let (handle_tx, handle_rx) = oneshot::channel::<()>();
    tokio::spawn(async move {
        let mut rx = LISTENER
            .get_or_init(|| {
                let (tx, _) = watch::channel(false);
                tx
            })
            .subscribe();

        let linstener = async {
            while let Ok(()) = rx.changed().await {
                let status = *rx.borrow_and_update();
                dart_callback(status).await;
            }
        };

        tokio::select! {
            _ = handle_rx => {},
            _ = linstener => {},
        };
    });
    ListenerHandle::new(handle_tx)
}

pub async fn stop_web_api() -> anyhow::Result<()> {
    let tx = HANDLE
        .get()
        .context("")?
        .lock()
        .take()
        .context("WebAPI instance not found")?;

    tx.send(()).await?;
    tracing::info!(target:"web_api","WebAPI instance stopped");
    Ok(())
}

pub fn web_api_status() -> anyhow::Result<bool> {
    Ok(HANDLE.get().context("")?.lock().is_some())
}

async fn shutdown_signal() {
    let mut rx = {
        let (tx, rx) = mpsc::channel(1);
        HANDLE
            .get_or_init(|| Mutex::new(None))
            .lock()
            .replace(tx.clone());
        rx
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = terminate => {},
        _ = rx.recv() => {

        },
    }

    LISTENER.get().unwrap().send(false).unwrap();

    HANDLE.get().unwrap().lock().take();
}
