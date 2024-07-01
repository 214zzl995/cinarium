use cinarium_crawler::Template;
use regex::Regex;
use std::{
    io::Cursor,
    path::{Path, PathBuf},
    sync::OnceLock,
};
use tokio::{fs::File, io::AsyncWriteExt};
use walkdir::WalkDir;

use crate::{
    app::get_cinarium_config,
    model::{Metadata, VideoDataInterim},
};

use super::TaskMetadata;

static CRAWLER_TEMPLATES: OnceLock<Vec<CrawlerTemplate>> = OnceLock::new();

#[derive(Debug, Clone)]
pub struct CrawlerTemplate {
    pub base_url: String,
    pub template: Template<VideoDataInterim>,
    pub error: Option<String>,
}

pub fn init_crawler_templates() -> anyhow::Result<()> {
    let mut templates = Vec::new();

    let template = CrawlerTemplate {
        base_url: "https://www.javdb.com".to_string(),
        template: Template::<VideoDataInterim>::from_json(include_str!(
            "../../cinarium-crawler/default/db.json"
        ))?,
        error: None,
    };

    templates.push(template);

    CRAWLER_TEMPLATES.set(templates).unwrap();

    Ok(())
}

pub fn get_crawler_templates() -> anyhow::Result<Vec<CrawlerTemplate>> {
    if CRAWLER_TEMPLATES.get().is_none() {
        init_crawler_templates()?;
    }

    Ok(CRAWLER_TEMPLATES.get().unwrap().clone())
}

impl Metadata {
    pub(super) async fn migration(
        &self,
        video_data_interim: &mut VideoDataInterim,
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

        Ok(())
    }
}

impl VideoDataInterim {
    pub async fn run(task_metadata: &TaskMetadata) -> anyhow::Result<()> {
        tracing::info!(target:"cinarium-task", "Crawling: {} ...", &task_metadata.name);
        let mut video_data_interim = Self::crawler(&task_metadata.name).await?;
        tracing::info!(target:"cinarium-task","Migrationimg: {} ...", &task_metadata.name);
        let video_matedata = Metadata::query_one(&task_metadata.video_id).await?;
        video_matedata.migration(&mut video_data_interim).await?;
        tracing::info!(target:"cinarium-task","Downloading Resources: {} ...", &task_metadata.name);
        video_data_interim.download_resources().await?;
        tracing::info!(target:"cinarium-task","Updating Video Data: {} ...", &task_metadata.name);
        video_data_interim.update(&task_metadata.video_id).await?;
        tracing::info!(target:"cinarium-task","Crawl Completed: {} ...", &task_metadata.name);
        Ok(())
    }

    pub(super) async fn download_resources(&self) -> anyhow::Result<()> {
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
        Ok(())
    }

    pub(super) async fn crawler(name: &str) -> anyhow::Result<Self> {
        for CrawlerTemplate {
            base_url,
            mut template,
            ..
        } in get_crawler_templates()?
        {
            template.add_parameters("crawl_name", name);
            template.add_parameters("base_url", &base_url);

            let url = format!("{}/search?q={}&f=all", base_url, name);

            match template.crawler(&url).await {
                Ok(data) => return Ok(data),
                Err(err) => {
                    tracing::error!(
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

    let mut bytes: Vec<u8> = Vec::new();

    image::load_from_memory(&image)?
        .write_to(&mut Cursor::new(&mut bytes), image::ImageFormat::WebP)?;

    let mut file = File::create(&image_path).await?;

    file.write_all(&image).await?;

    Ok(())
}
