extern crate anyhow;

mod api;
mod app;
mod log;
mod model;
mod native;
mod notify;
mod task;

use std::{net::TcpListener, path::PathBuf};

use anyhow::Context;
use app::HttpConfig;
use model::{Metadata, UntreatedVideo, VideoDataInterim};
use prettytable::{row, Table};
use structopt::StructOpt;
use task::TaskMetadata;

pub use task::crawler::Template;

#[derive(StructOpt, Debug)]
#[structopt(name = "cinarium")]
enum Opt {
    #[structopt(name = "api", about = "Launching Web Api")]
    Api {
        #[structopt(
            short,
            long,
            about = "Port to listen on",
            help = "Get a random free port if it is empty and the configuration file is empty"
        )]
        port: Option<u16>,
    },
    #[structopt(name = "crawler", about = "Launching Crawler")]
    Crawler {
        #[structopt(
            short,
            long,
            about = "Hash of the video file",
            help = "Enter a hash value that has already been indexed",
            required_if("path", "None")
        )]
        hash: Option<String>,
        #[structopt(
            short,
            long,
            about = "Filename of the video file",
            help = "Enter a Path value and set new to true if it is not included.",
            required_if("hash", "None"),
            required_if("new", "true")
        )]
        path: Option<PathBuf>,
        #[structopt(
            short,
            long,
            help = "Whether or not the video is non-database included"
        )]
        new: bool,
        crawl_name: String,
    },
    #[structopt(name = "list", about = "Files that have been monitored")]
    List {
        #[structopt(short, long, about = "Search for files that have been monitored")]
        search: Option<String>,
    },
}

#[tokio::main]
async fn main() {
    let opt = Opt::from_args();
    log::register_log().unwrap();
    app::init_cinarium_config().await.unwrap();
    notify::init_source_notify().await.unwrap();
    task::crawler::init_crawler_templates().await.unwrap();

    let res = match opt {
        Opt::Api { .. } => api::run_web_api().await,
        Opt::Crawler {
            hash,
            path,
            crawl_name,
            new,
        } => crawler(hash, path, crawl_name, new).await,
        Opt::List { search } => search_videos(&search).await,
    };

    if let Err(res) = res {
        tracing::error!("{:?}", res);
    };
}

impl Default for HttpConfig {
    fn default() -> Self {
        let port = match crate::Opt::from_args() {
            crate::Opt::Api { port } => port.unwrap_or(get_free_port()),
            _ => get_free_port(),
        };
        HttpConfig { port }
    }
}

fn get_free_port() -> u16 {
    let listener = TcpListener::bind("127.0.0.1:0").unwrap();
    let port = listener.local_addr().unwrap().port();
    port
}

pub fn get_web_api_port() -> Option<u16> {
    match Opt::from_args() {
        Opt::Api { port } => port,
        _ => None,
    }
}

async fn search_videos(filename: &Option<String>) -> anyhow::Result<()> {
    let videos = match filename {
        Some(search) => Metadata::query_by_filename(&search).await?,
        None => Metadata::query_all().await?,
    };

    let mut table = Table::new();

    table.add_row(row!["Hash", "Path"]);
    for video in videos {
        table.add_row(row![
            video.hash,
            format!(
                "{}\\{}.{}",
                video.path.to_str().unwrap(),
                video.filename,
                video.extension
            )
        ]);
    }

    table.printstd();
    Ok(())
}

async fn crawler(
    hash: Option<String>,
    path: Option<PathBuf>,
    crawl_name: String,
    new: bool,
) -> anyhow::Result<()> {
    if let Some(path) = &path {
        if !path.exists() {
            return Err(anyhow::anyhow!("{} does not exist", path.display()));
        }

        if path.is_dir() {
            return Err(anyhow::anyhow!("{} is a directory", path.display()));
        }
    }

    let id = if new {
        let path = path.context("Please provide a path")?;
        match Metadata::try_from(&path)?
            .insert_with_crawl_name(&crawl_name)
            .await?
        {
            Some(id) => id,
            None => return Err(anyhow::anyhow!("The video file already exists")),
        }
    } else {
        if let Some(hash) = hash {
            UntreatedVideo::update_crawl_name_with_hash(&hash, &crawl_name).await
        } else if let Some(path) = path {
            UntreatedVideo::update_crawl_name_with_path(&path, &crawl_name).await
        } else {
            Err(anyhow::anyhow!("Please provide a hash or path"))
        }?
    };

    let task_metadata = TaskMetadata {
        video_id: id,
        name: crawl_name,
    };
    VideoDataInterim::run(&task_metadata).await?;
    Ok(())
}
