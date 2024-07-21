pub use cinarium_crawler::Template;
use flutter_rust_bridge::frb;
use image::ImageFormat;
use parking_lot::Mutex;
use regex::Regex;
use std::{
    io::Cursor,
    path::{Path, PathBuf},
};
use tokio::{fs::File, io::{AsyncWriteExt, BufWriter}, sync::OnceCell};
use walkdir::WalkDir;

use crate::{
    app::get_cinarium_config,
    model::{Metadata, VideoDataInterim},
};

use super::TaskMetadata;

static CRAWLER_TEMPLATES: OnceCell<Mutex<Vec<CrawlerTemplate>>> = OnceCell::const_new();

#[derive(Debug, Clone)]
#[frb(non_opaque)]
pub struct CrawlerTemplate {
    pub id: u32,
    pub base_url: String,
    pub search_url: String,
    pub json_raw: String,
    pub template: Template<VideoDataInterim>,
    pub priority: u8,
    pub enabled: bool,
}

pub async fn init_crawler_templates() -> anyhow::Result<()> {
    if CRAWLER_TEMPLATES.initialized() {
        return Ok(());
    }

    let templates = Mutex::new(CrawlerTemplate::get_crawler_templates().await?);

    CRAWLER_TEMPLATES.set(templates).unwrap();

    Ok(())
}

pub fn get_crawler_templates() -> anyhow::Result<Vec<CrawlerTemplate>> {
    if !CRAWLER_TEMPLATES.initialized() {
        panic!("Crawler templates not initialized")
    }
    Ok(CRAWLER_TEMPLATES.get().unwrap().lock().clone())
}

pub async fn change_crawler_templates_priority(prioritys: Vec<(u32, u8)>) -> anyhow::Result<()> {
    {
        let mut templates = CRAWLER_TEMPLATES.get().unwrap().lock();
        for (id, priority) in prioritys.clone() {
            if let Some(template) = templates.iter_mut().find(|t| t.id == id) {
                template.priority = priority;
            }
        }
    }
    CrawlerTemplate::update_priority(&prioritys).await?;

    Ok(())
}

pub async fn switch_crawler_templates_enabled(id: u32) -> anyhow::Result<()> {
    {
        let mut templates = CRAWLER_TEMPLATES.get().unwrap().lock();
        if let Some(template) = templates.iter_mut().find(|t| t.id == id) {
            template.enabled = !template.enabled;
        }
    }
    CrawlerTemplate::switch_enabled(&id).await?;

    Ok(())
}

impl Metadata {
    pub(super) async fn migration(
        &self,
        video_data_interim: &mut VideoDataInterim,
        video_id: &u32,
    ) -> anyhow::Result<()> {
        let tidy_path = get_cinarium_config().task.tidy_folder;
        let embedded_subtitles = self.filename.ends_with("-c") || self.filename.ends_with("-C");
        video_data_interim.embedded_subtitles = embedded_subtitles;
        let file_name = format!("{}.{}", &self.filename, &self.extension);

        let maybe_subtitles = find_any_subtitles(&self.path, &file_name);
        let to_path = tidy_path.join(&video_data_interim.name);
        let to_file_name = format!("{}.{}", &video_data_interim.name, &self.extension);
        if !to_path.exists() {
            tokio::fs::create_dir_all(&to_path).await?;
        }

        let from_path =
            PathBuf::from(&self.path).join(format!("{}.{}", &self.filename, &self.extension));

        let mut crosses_devices = false;

        if let Err(err) = tokio::fs::rename(&from_path, to_path.join(&to_file_name)).await {
            if err.raw_os_error() == Some(17) {
                crosses_devices = true;
                tokio::fs::copy(&from_path, to_path.join(&to_file_name)).await?;
                tokio::fs::remove_file(&from_path).await?;
            } else {
                return Err(err.into());
            }
        }

        if let Some(subtitles) = maybe_subtitles {
            let to_subtitles_name = format!(
                "{}.{}",
                &video_data_interim.name,
                &subtitles.extension().unwrap().to_str().unwrap()
            );
            if crosses_devices {
                tokio::fs::copy(&subtitles, to_path.join(&to_subtitles_name)).await?;
                tokio::fs::remove_file(&subtitles).await?;
            } else {
                tokio::fs::rename(subtitles, to_path.join(&to_subtitles_name)).await?;
            }
        };

        Self {
            filename: video_data_interim.name.clone(),
            hash: self.hash.clone(),
            path: to_path,
            size: self.size,
            extension: self.extension.clone(),
        }
        .update(video_id)
        .await?;

        Ok(())
    }
}

impl VideoDataInterim {
    pub async fn run(task_metadata: &TaskMetadata) -> anyhow::Result<()> {
        tracing::info!(target:"cinarium-task", "Crawling: {} ...", &task_metadata.name);
        let mut video_data_interim = Self::crawler(&task_metadata.name).await?;
        tracing::info!(target:"cinarium-task","Migrationimg: {} ...", &task_metadata.name);
        let video_matedata = Metadata::query_one(&task_metadata.video_id).await?;
        video_matedata
            .migration(&mut video_data_interim, &task_metadata.video_id)
            .await?;
        tracing::info!(target:"cinarium-task","Downloading Resources: {} ...", &task_metadata.name);
        video_data_interim.download_resources().await?;
        tracing::info!(target:"cinarium-task","Updating Video Data: {} ...", &task_metadata.name);
        video_data_interim.update(&task_metadata.video_id).await?;
        tracing::info!(target:"cinarium-task","Crawl Completed: {} ...", &task_metadata.name);
        Ok(())
    }

    pub(super) async fn download_resources(&mut self) -> anyhow::Result<()> {
        let base_path = PathBuf::from(&get_cinarium_config().task.tidy_folder).join(&self.name);
        let main_with_thumb_path = base_path.join("img");
        let detail_path = main_with_thumb_path.join("detail");

        if !detail_path.exists() {
            tokio::fs::create_dir_all(&detail_path).await?;
        }

        tracing::info!(target:"cinarium-task","Downloading Images: {} ...", &self.name);
        tracing::info!(target:"cinarium-task",
            "Downloading Main Image: {} , Path: {}.webp",
            &self.main_image,
            &main_with_thumb_path.display()
        );
        save_image(&self.main_image, "main", &main_with_thumb_path).await?;

        tracing::info!(target:"cinarium-task",
            "Downloading Thumbnail Image: {} , Path: {}.webp",
            &self.thumbnail,
            &main_with_thumb_path.display()
        );
        save_image(&self.thumbnail, "thumbnail", &main_with_thumb_path).await?;

        for (index, image) in self.detail_imgs.iter().enumerate() {
            let image_name = format!("detail_{}", index);
            tracing::info!(target:"cinarium-task",
                "Downloading Detail Image: {} , Path: {}.webp",
                &image,
                &detail_path.display()
            );
            save_image(image, &image_name, &detail_path).await?;
        }

        let thumbnail = image::open(main_with_thumb_path.join("thumbnail.webp"))?;
        let thumbnail_ratio = thumbnail.width() as f32 / thumbnail.height() as f32;
        self.thumbnail_ratio = thumbnail_ratio;

        self.num_detail_images = self.detail_imgs.len() as u8;

        Ok(())
    }

    pub(super) async fn crawler(name: &str) -> anyhow::Result<Self> {
        let mut templates = get_crawler_templates()?;
        templates.sort_by(|a, b| a.priority.cmp(&b.priority));
        for CrawlerTemplate {
            base_url,
            search_url,
            mut template,
            ..
        } in templates
        {
            template.add_parameters("crawl_name", name);
            template.add_parameters("base_url", &base_url);

            let url = search_url.replace("${base_url}", &base_url).replace("${crawl_name}", name);

            match template.crawler(&url).await {
                Ok(data) => return Ok(data),
                Err(err) => {
                    tracing::error!(target:"cinarium-task",
                        "Template:Crawl Failed,Error Reason:{},Switch to Next Template",
                        err
                    );
                }
            }
        }
        Err(anyhow::anyhow!("All templates failed to crawl"))
    }
}

fn get_reg_name(name: &str) -> String {
    Regex::new(r"[^a-zA-Z0-9]")
        .unwrap()
        .replace_all(name, "")
        .to_ascii_lowercase()
}

fn find_any_subtitles(path: &PathBuf, comparison_name: &str) -> Option<PathBuf> {
    let dir = WalkDir::new(path);
    let comparison_name = get_reg_name(comparison_name);

    dir.into_iter().find_map(|entry| {
        if let Ok(entry) = entry {
            let entry_path = entry.path();
            let extension = entry_path.extension().unwrap_or_default().to_str().unwrap();
            if is_subtitles_type(&extension.to_lowercase()) {
                let file_name = entry_path.file_stem().unwrap().to_str().unwrap();
                let reg_name = get_reg_name(file_name);
                if reg_name.contains(&comparison_name) {
                    return Some(entry_path.to_path_buf());
                }
            }
        };
        None::<PathBuf>
    })
}


fn check_single_video_file(path: &PathBuf, video_file_name: &str) -> bool {
    let dir = WalkDir::new(path);
    dir.into_iter().any(|entry| {
        if let Ok(entry) = entry {
            if entry.path().is_file() && entry.path().file_name().unwrap() != video_file_name {
                let extension = entry
                    .path()
                    .extension()
                    .unwrap_or_default()
                    .to_str()
                    .unwrap();
                return is_mov_type(&extension.to_lowercase());
            }
        };
        false
    })
}

fn is_mov_type(extension: &str) -> bool {
    matches!(
        extension,
        "mov" | "mp4" | "mkv" | "avi" | "wmv" | "flv" | "rmvb" | "rm" | "3gp"
    )
}

fn is_subtitles_type(extension: &str) -> bool {
    matches!(
        extension,
        "srt" | "vtt" | "ass" | "ssa" | "ttml" | "sub" | "idx"
    )
}

pub async fn save_image(url: &str, name: &str, path: &Path) -> anyhow::Result<()> {
    let image_path = path.join(format!("{}.webp", name));

    let mut request_num = 1;
    let mut res = reqwest::get(url).await;
    while request_num != 2 {
        match res {
            Ok(_) => break,
            Err(_) => {
                request_num += 1;
                res = reqwest::get(url).await;
            }
        }
    }

    let image = res?.bytes().await?;

    let image = image::load_from_memory(&image)?;

    let mut buffer = Cursor::new(Vec::new());

    image.write_to(&mut buffer, ImageFormat::WebP)?;

    let file = File::create(&image_path).await?;

    let mut buf_writer = BufWriter::new(file);

    buf_writer.write_all(&buffer.into_inner()).await?;
    buf_writer.flush().await?;

    Ok(())
}
