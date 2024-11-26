use std::{collections::HashSet, path::PathBuf, sync::Arc};

use notify::{
    event::{ModifyKind, RenameMode},
    Config, Error, Event, RecommendedWatcher, Watcher,
};
use parking_lot::Mutex;
use tokio::sync::{broadcast, mpsc};

use crate::model::{Metadata, Source};

use super::{is_mov_type, is_recycle_bin, UntreatedVideoEvent};

#[derive(Clone)]
pub struct SourceNotify(Arc<Mutex<SourceNotifyInner>>);

pub struct SourceNotifyInner {
    watcher: RecommendedWatcher,
    sources: Vec<Source>,
    //Doing anti-shake for inserts and deletes sqlite databases can't afford fast processing of single entries
    modifys: HashSet<PathBuf>,
    deleted: HashSet<PathBuf>,
}

impl SourceNotify {
    pub(super) fn new(
        sources: &[Source],
        tx: mpsc::UnboundedSender<std::result::Result<Event, Error>>,
    ) -> anyhow::Result<Self> {
        let watcher = RecommendedWatcher::new(
            move |result: std::result::Result<Event, Error>| {
                tx.send(result).unwrap();
            },
            Config::default(),
        )?;

        Ok(SourceNotify(Arc::new(Mutex::new(SourceNotifyInner {
            watcher,
            sources: sources.to_owned(),
            modifys: HashSet::new(),
            deleted: HashSet::new(),
        }))))
    }

    fn add_modify_path(&self, path: PathBuf) {
        self.0.lock().modifys.insert(path);
    }

    fn add_deleted_path(&self, path: PathBuf) {
        self.0.lock().deleted.insert(path);
    }

    pub(super) fn listen(
        &self,
        return_tx: mpsc::Sender<UntreatedVideoEvent>,
        mut rx: mpsc::UnboundedReceiver<Result<Event, Error>>,
        dispose_tx: broadcast::Sender<()>,
    ) {
        let source_notify = self.clone();
        let listen_handle = async move {
            while let Some(Ok(event)) = rx.recv().await {
                let source_notify = source_notify.clone();
                tokio::spawn(async move {
                    match event.kind {
                        notify::EventKind::Create(_) => {
                            let path = event.paths.first().unwrap().clone();
                            if !path.is_file() {
                                return;
                            }
                            #[cfg(target_os = "windows")]
                            if is_recycle_bin(&path) {
                                return;
                            }
                            if is_mov_type(path.extension().unwrap().to_str().unwrap()) {}
                        }
                        notify::EventKind::Remove(_) => {
                            let path = event.paths.first().unwrap().clone();
                            // Files that have been deleted will get a non-file judgment because of the lack of metadata
                            if path.extension().is_none() {
                                return;
                            }
                            #[cfg(target_os = "windows")]
                            if is_recycle_bin(&path) {
                                return;
                            }

                            if is_mov_type(path.extension().unwrap().to_str().unwrap()) {
                                source_notify.add_deleted_path(path);
                            }
                        }
                        notify::EventKind::Modify(modify_kind) => {
                            if modify_kind == ModifyKind::Any
                                || modify_kind == ModifyKind::Name(RenameMode::To)
                            {
                                let path = event.paths.first().unwrap().clone();

                                if !path.is_file() {
                                    return;
                                }
                                #[cfg(target_os = "windows")]
                                if is_recycle_bin(&path) {
                                    return;
                                }

                                if is_mov_type(path.extension().unwrap().to_str().unwrap()) {
                                    source_notify.add_modify_path(path);
                                }
                            }
                        }
                        _ => {}
                    }
                });
            }
        };

        let mut dispose_rx = dispose_tx.subscribe();

        tokio::spawn(async move {
            tokio::select! {
                _ = listen_handle => {},
                _ = dispose_rx.recv() => {},
            };
        });

        {
            let mut source_notify = self.0.lock();

            let sources = source_notify.sources.clone();

            for source in sources {
                source_notify
                    .watcher
                    .watch(
                        std::path::Path::new(&source.path),
                        ::notify::RecursiveMode::Recursive,
                    )
                    .unwrap();
            }
        }

        let source_notify = self.clone();

        let return_handle = async move {
            // n seconds to assemble an update statement Prevents transactions from being too frequent
            loop {
                tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;

                let (modifys, deleted) = {
                    let mut source_notify = source_notify.0.lock();

                    // Modifying a file may fail to fetch metadata, and will be put into the next process.
                    let mut modifys = Vec::new();
                    for path in source_notify.modifys.clone().iter() {
                        match Metadata::try_from(path) {
                            Ok(metadata) => {
                                modifys.push(metadata);
                                source_notify.modifys.remove(path);
                            }
                            // Possible scenario: File busy
                            Err(_) => {}
                        }
                    }
                    let deleted = source_notify.deleted.drain().collect::<Vec<PathBuf>>();

                    source_notify.deleted.clear();

                    (modifys, deleted)
                };

                if !modifys.is_empty() {
                    return_tx
                        .send(UntreatedVideoEvent::InsertOrUpdate(modifys))
                        .await
                        .unwrap();
                }

                if !deleted.is_empty() {
                    return_tx
                        .send(UntreatedVideoEvent::Remove(deleted))
                        .await
                        .unwrap();
                }
            }
        };

        let mut dispose_rx = dispose_tx.subscribe();

        tokio::spawn(async move {
            tokio::select! {
                _ = return_handle => {},
                _ = dispose_rx.recv() => {},
            };
        });
    }

    pub(super) fn paths(&self) -> Vec<PathBuf> {
        let mut sources = self
            .0
            .lock()
            .sources
            .clone()
            .into_iter()
            .collect::<Vec<Source>>();

        sources.sort_by(|a, b| a.id.cmp(&b.id));

        sources.into_iter().map(|s| s.path).collect()
    }

    pub(super) fn watch_source(&self, source: &Source) -> anyhow::Result<()> {
        let mut source_notify = self.0.lock();
        source_notify.sources.push(source.clone());
        source_notify.watcher.watch(
            std::path::Path::new(&source.path),
            ::notify::RecursiveMode::Recursive,
        )?;

        Ok(())
    }

    pub(super) fn unwatch_source(&self, source: &Source) -> anyhow::Result<()> {
        self.0.lock().sources.retain(|s| s.id != source.id);
        self.0.lock().watcher.unwatch(&source.path)?;
        Ok(())
    }

    pub(super) fn sources(&self) -> Vec<Source> {
        self.0.lock().sources.clone()
    }
}

impl SourceNotifyInner {}
