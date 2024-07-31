use std::{
    collections::HashSet,
    path::{Path, PathBuf},
    str::FromStr,
};

use crate::anyhow::Context;
use crate::model::get_pool;
use cinarium_crawler_derive::Crawler;
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use sqlx::{QueryBuilder, Sqlite, Transaction};

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow)]
#[frb(non_opaque)]
pub struct HomeVideo {
    pub id: u32,
    pub name: String,
    pub title: String,
    pub release_time: String,
    pub duration: u32,
    pub thumbnail_ratio: f32,
    #[sqlx(flatten)]
    pub matedata: Metadata,
}

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow)]
#[frb(non_opaque)]
pub struct UntreatedVideo {
    pub id: u32,
    pub crawl_name: String,
    pub is_hidden: bool,
    #[sqlx(flatten)]
    pub matedata: Metadata,
}

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow)]
#[frb(non_opaque)]
pub struct DetailVideo {
    pub id: u32,
    pub name: String,
    #[sqlx(flatten)]
    pub matedata: Metadata,
    #[sqlx(flatten)]
    pub data: VideoData,
}

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow)]
#[frb(opaque)]
pub struct Metadata {
    pub hash: String,
    pub filename: String,
    #[sqlx(try_from = "String")]
    pub path: PathBuf,
    #[sqlx(try_from = "i64")]
    pub size: u64,
    pub extension: String,
}

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow)]
#[frb(non_opaque)]
pub struct VideoData {
    pub title: String,
    pub release_time: String,
    pub duration: u32,
    pub maker: Option<Attr>,
    pub publisher: Option<Attr>,
    pub series: Option<Attr>,
    pub director: Option<Attr>,
    pub tags: Vec<Attr>,
    pub actors: Vec<Attr>,
    pub num_detail_images: u8,
    pub thumbnail_ratio: f32,
    pub embedded_subtitles: bool,
    pub subtitles: Vec<String>,
}

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow, Default, Crawler)]
pub struct VideoDataInterim {
    pub name: String,
    pub title: String,
    pub release_time: String,
    pub duration: u32,
    pub makers: Option<AttrInterim>,
    pub publisher: Option<AttrInterim>,
    pub series: Option<AttrInterim>,
    pub director: Option<AttrInterim>,
    pub tags: Vec<AttrInterim>,
    pub actors: Vec<AttrInterim>,
    pub detail_imgs: Vec<String>,
    pub main_image: String,
    pub thumbnail: String,
    #[crawler(skip)]
    pub num_detail_images: u8,
    #[crawler(skip)]
    pub thumbnail_ratio: f32,
    #[crawler(skip)]
    pub embedded_subtitles: bool,
}

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow)]
pub struct RelatedAttr {
    pub video_id: u32,
    pub attr_id: u32,
}

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow)]
pub struct Attr {
    pub id: u32,
    pub name: String,
}

#[derive(Debug, Deserialize, Serialize, Clone, sqlx::FromRow)]
pub struct AttrInterim(String);

impl FromStr for AttrInterim {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(AttrInterim(s.to_string()))
    }
}

impl HomeVideo {
    pub async fn query_all() -> sqlx::Result<Vec<Self>> {
        let videos = sqlx::query_as(
            r#"
                select id, name, title, duration, thumbnail_ratio, release_time, hash, filename, path, size, extension
                from video
                where is_retrieve = true
            "#,
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(videos)
    }

    pub async fn query_paging(page_size: &usize, page_num: &usize) -> sqlx::Result<Vec<Self>> {
        let videos = sqlx::query_as(
            r#"
                select id, name, title, duration, thumbnail_ratio, release_time, hash, filename, path, size, extension
                from video
                where is_retrieve = true
                limit $1 offset $2
            "#,
        )
        .bind(*page_size as u32)
        .bind(*page_size as u32 * *page_num as u32)
        .fetch_all(get_pool().await)
        .await?;

        Ok(videos)
    }
}

impl RelatedAttr {
    pub async fn query_all_video_actors() -> anyhow::Result<Vec<Self>> {
        let actors = sqlx::query_as!(
            Self,
            r#"
                select video_id as "video_id!:u32", actor_id as "attr_id!:u32"
                from video_actors
            "#,
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(actors)
    }

    pub async fn query_all_video_tags() -> anyhow::Result<Vec<Self>> {
        let tags = sqlx::query_as!(
            Self,
            r#"
                select video_id as "video_id!:u32", tag_id as "attr_id!:u32"
                from video_tags
            "#,
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(tags)
    }

    pub async fn query_all_video_makers() -> anyhow::Result<Vec<Self>> {
        let makers = sqlx::query_as!(
            Self,
            r#"
                select a.id as "video_id!:u32", b.id as "attr_id!:u32"
                from video a, maker b
                where a.maker_id = b.id
            "#,
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(makers)
    }

    pub async fn query_all_video_publishers() -> anyhow::Result<Vec<Self>> {
        let publishers = sqlx::query_as!(
            Self,
            r#"
                select a.id as "video_id!:u32", b.id as "attr_id!:u32"
                from video a, publisher b
                where a.publisher_id = b.id
            "#,
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(publishers)
    }

    pub async fn query_all_video_series() -> anyhow::Result<Vec<Self>> {
        let series = sqlx::query_as!(
            Self,
            r#"
                select a.id as "video_id!:u32", b.id as "attr_id!:u32"
                from video a, series b
                where a.series_id = b.id
            "#,
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(series)
    }

    pub async fn query_all_video_directors() -> anyhow::Result<Vec<Self>> {
        let directors = sqlx::query_as!(
            Self,
            r#"
                select a.id as "video_id!:u32", b.id as "attr_id!:u32"
                from video a, director b
                where a.director_id = b.id
            "#,
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(directors)
    }
}

impl UntreatedVideo {
    pub async fn query_all() -> anyhow::Result<Vec<Self>> {
        let task_videos = sqlx::query_as(
            r#"
                select id, crawl_name, is_hidden,hash, filename, path, size, extension
                from video
                where is_retrieve = false
            "#,
        )
        .fetch_all(get_pool().await)
        .await?;
        Ok(task_videos)
    }

    pub async fn update_crawl_name_with_id(id: &u32, crawl_name: &str) -> anyhow::Result<()> {
        sqlx::query!(
            r#"
                update video
                set crawl_name = $1
                where id = $2
            "#,
            crawl_name,
            id
        )
        .execute(get_pool().await)
        .await?;
        Ok(())
    }

    #[allow(dead_code)]
    pub async fn update_crawl_name_with_hash(hash: &str, crawl_name: &str) -> anyhow::Result<u32> {
        let id = sqlx::query!(
            r#"
                update video
                set crawl_name = $1
                where hash = $2
                returning id as "id!:u32"
            "#,
            crawl_name,
            hash
        )
        .fetch_one(get_pool().await)
        .await
        .context("No video found with the given hash")?;
        Ok(id.id)
    }

    #[allow(dead_code)]
    pub async fn update_crawl_name_with_path(path: &Path, crawl_name: &str) -> anyhow::Result<u32> {
        let filename = path
            .file_stem()
            .context("Unable to get file name")?
            .to_str()
            .unwrap();
        let extension = path
            .extension()
            .context("Unable to get file extension")?
            .to_str()
            .unwrap();
        let path = path.parent().unwrap().to_string_lossy().to_string();

        let id = sqlx::query!(
            r#"
                update video
                set crawl_name = $1
                where path = $2 and filename = $3 and extension = $4
                returning id as "id!:u32"
            "#,
            crawl_name,
            path,
            filename,
            extension
        )
        .fetch_one(get_pool().await)
        .await
        .context("No video found with the given path")?;

        Ok(id.id)
    }

    pub async fn switch_videos_hidden(ids: Vec<u32>) -> anyhow::Result<()> {
        let ids = ids
            .iter()
            .map(|x| x.to_string())
            .collect::<Vec<_>>()
            .join(",");

        sqlx::query!(
            r#"
                    update video
                    set is_hidden = not is_hidden
                    where id in ($1)
                "#,
            ids
        )
        .execute(get_pool().await)
        .await?;

        Ok(())
    }

    #[allow(dead_code)]
    pub async fn query_one(id: &u32) -> anyhow::Result<Self> {
        let task_video = sqlx::query_as(
            r#"
                select id, crawl_name, is_hidden, hash, filename, path, size, extension
                from video
                where id = $1
            "#,
        )
        .bind(id)
        .fetch_one(get_pool().await)
        .await?;

        Ok(task_video)
    }
}

impl DetailVideo {
    pub async fn query_by_id(id: &u32) -> sqlx::Result<DetailVideo> {
        let video = sqlx::query!(
            r#"
             select a.id, a.name as "name!", hash as "hash!", filename as "filename!", title as "title!", path as "path!", size as "size!:i64", extension as "extension!", 
                    release_time as "release_time!", duration as "duration!:u32", maker_id as "maker_id?:u32",
                    b.name as maker_name, publisher_id as "publisher_id?:u32", c.name as publisher_name,
                    series_id as "series_id?:u32", d.name as series_name, director_id as "director_id?:u32", e.name as director_name,
                    embedded_subtitles as "embedded_subtitles!",num_detail_images as "num_detail_images!:u8",thumbnail_ratio as "thumbnail_ratio!:f32"
             from video a
                      left join maker b on a.maker_id = b.id
                      left join publisher c on a.publisher_id = c.id
                      left join series d on a.series_id = d.id
                      left join director e on a.director_id = e.id
             where a.id = ? 
            "#,id
        )
            .fetch_one(get_pool().await)
            .await?;

        let maker = video.maker_id.map(|maker| Attr {
            id: maker,
            name: video.maker_name.unwrap(),
        });

        let publisher = video.publisher_id.map(|publisher| Attr {
            id: publisher,
            name: video.publisher_name.unwrap(),
        });

        let series = video.series_id.map(|series| Attr {
            id: series,
            name: video.series_name.unwrap(),
        });

        let director = video.director_id.map(|director| Attr {
            id: director,
            name: video.director_name.unwrap(),
        });

        let tags = sqlx::query_as!(
            Attr,
            r#"
                select tag.id as "id!:u32", tag.name as "name!"
                from tag, video_tags
                where tag.id = video_tags.tag_id and video_tags.video_id = ?
            "#,
            id
        )
        .fetch_all(get_pool().await)
        .await?;

        let actors = sqlx::query_as!(
            Attr,
            r#"
                select actor.id as "id!:u32", actor.name as "name!"
                from actor, video_actors
                where actor.id = video_actors.actor_id and video_actors.video_id = ?
            "#,
            id
        )
        .fetch_all(get_pool().await)
        .await?;

        let detail_video = Self {
            id: *id,
            name: video.name,
            matedata: Metadata {
                hash: video.hash,
                filename: video.filename,
                path: PathBuf::from(video.path),
                size: video.size as u64,
                extension: video.extension,
            },
            data: VideoData {
                title: video.title,
                release_time: video.release_time,
                duration: video.duration,
                maker,
                publisher,
                series,
                director,
                tags,
                actors,
                thumbnail_ratio: video.thumbnail_ratio,
                num_detail_images: video.num_detail_images,
                embedded_subtitles: video.embedded_subtitles,
                subtitles: vec![],
            },
        };

        Ok(detail_video)
    }
}

impl Metadata {
    #[allow(dead_code)]
    pub async fn insert(&self) -> anyhow::Result<u32> {
        let path = self.path.to_string_lossy().to_string();
        let size = self.size as i64;
        let id = sqlx::query!(
            r#"
                insert into video (hash, filename, path, size, extension)
                values ($1, $2, $3, $4, $5)
                returning id as "id!:u32"
            "#,
            self.hash,
            self.filename,
            path,
            size,
            self.extension
        )
        .fetch_one(get_pool().await)
        .await
        .context("Insert video failed: Video already exists ")?
        .id;

        Ok(id)
    }

    #[allow(dead_code)]
    pub async fn insert_with_crawl_name(&self, crawl_name: &str) -> anyhow::Result<Option<u32>> {
        let path = self.path.to_string_lossy().to_string();
        let size = self.size as i64;
        let id = sqlx::query!(
            r#"
                insert or ignore into video (hash, filename, path, size, extension, crawl_name)
                values ($1, $2, $3, $4, $5, $6)
                returning id as "id!:u32"
            "#,
            self.hash,
            self.filename,
            path,
            size,
            self.extension,
            crawl_name
        )
        .fetch_optional(get_pool().await)
        .await?
        .map(|x| x.id);

        Ok(id)
    }

    #[allow(dead_code)]
    pub async fn insert_replace_batch(videos: &Vec<Metadata>) -> anyhow::Result<()> {
        let mut transaction = get_pool().await.begin().await?;
        let mut query_builder: QueryBuilder<Sqlite> = QueryBuilder::new(
            r#"
                insert or replace into video (hash, filename, path, size, extension, is_deleted)
            "#,
        );

        // Also update the is_deleted flag to prevent possible moves to other folders and back.
        query_builder.push_values(videos, |mut b, video| {
            b.push_bind(&video.hash)
                .push_bind(&video.filename)
                .push_bind(video.path.to_str())
                .push_bind(video.size as i64)
                .push_bind(&video.extension)
                .push_bind(false);
        });

        let query = query_builder.build();

        query.execute(&mut *transaction).await?;

        transaction.commit().await?;
        Ok(())
    }

    #[allow(dead_code)]
    pub async fn marking_delete_batch_with_hash(hashs: &[String]) -> anyhow::Result<()> {
        let hashs = hashs.join("','");

        let raw_sql = format!(
            r#"
                update video
                set is_deleted = true
                where hash in ('{}')
            "#,
            hashs
        );

        sqlx::query(&raw_sql).execute(get_pool().await).await?;

        Ok(())
    }

    #[allow(dead_code)]
    pub async fn marking_delete_with_path(path: &Path) -> anyhow::Result<()> {
        let filename = path
            .file_stem()
            .context("Unable to get file name")?
            .to_str()
            .unwrap();

        let extension = path
            .extension()
            .context("Unable to get file extension")?
            .to_str()
            .unwrap();
        let path = path.parent().unwrap().to_string_lossy().to_string();

        sqlx::query!(
            r#"
                update video
                set is_deleted = true
                where path = $1 and filename = $2 and extension = $3
            "#,
            path,
            filename,
            extension
        )
        .execute(get_pool().await)
        .await?;

        Ok(())
    }

    pub async fn query_one(id: &u32) -> anyhow::Result<Self> {
        let video = sqlx::query_as!(Self,
            r#"
                select hash as "hash!" ,filename as "filename!", path as "path!", size as "size!:u32", extension as "extension!"
                from video
                where id = ?
            "#,
            id
        )
        .fetch_one(get_pool().await)
        .await?;

        Ok(video)
    }

    pub async fn update(&self, id: &u32) -> anyhow::Result<()> {
        let path = self.path.to_string_lossy().to_string();
        let size = self.size as i64;
        sqlx::query!(
            r#"
                update video
                set filename = $1, path = $2, size = $3, extension = $4
                where id = $5 
            "#,
            self.filename,
            path,
            size,
            self.extension,
            id
        )
        .execute(get_pool().await)
        .await?;

        Ok(())
    }

    #[allow(dead_code)]
    pub async fn query_all_path() -> anyhow::Result<HashSet<(String, PathBuf)>> {
        let paths = sqlx::query!(
            r#"
                select hash as "hash!", path || '/' || filename || '.' || extension as "path!"
                from video
                where is_deleted = false
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(paths.into_iter().map(|x| (x.hash, x.path.into())).collect())
    }

    #[allow(dead_code)]
    pub async fn query_by_filename(filename: &str) -> anyhow::Result<Vec<Self>> {
        let filename = format!("%{}%", filename);
        let videos = sqlx::query_as!(Self,
            r#"
                select hash as "hash!", filename as "filename!", path as "path!", size as "size!:u32", extension as "extension!"
                from video
                where filename like $1
                and is_retrieve = false
            "#,
            filename
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(videos)
    }

    #[allow(dead_code)]
    pub async fn query_all() -> anyhow::Result<Vec<Self>> {
        let videos = sqlx::query_as!(Self,
            r#"
                select hash as "hash!", filename as "filename!", path as "path!", size as "size!:u32", extension as "extension!"
                from video
                where is_retrieve = false
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(videos)
    }

    #[allow(dead_code)]
    pub async fn query_id_by_hash(hash: &str) -> anyhow::Result<Option<u32>> {
        let id = sqlx::query!(
            r#"
                select id as "id!:u32"
                from video
                where hash = $1
            "#,
            hash
        )
        .fetch_optional(get_pool().await)
        .await?
        .map(|x| x.id);

        Ok(id)
    }

    #[allow(dead_code)]
    pub async fn query_id_by_path(path: &Path) -> anyhow::Result<Option<u32>> {
        let filename = path
            .file_stem()
            .context("Unable to get file name")?
            .to_str()
            .unwrap();
        let extension = path
            .extension()
            .context("Unable to get file extension")?
            .to_str()
            .unwrap();
        let path = path.parent().unwrap().to_string_lossy().to_string();

        let id = sqlx::query!(
            r#"
                select id as "id!:u32"
                from video
                where path = $1 and filename = $2 and extension = $3
            "#,
            path,
            filename,
            extension
        )
        .fetch_optional(get_pool().await)
        .await?
        .map(|x| x.id);

        Ok(id)
    }
}

impl VideoDataInterim {
    pub async fn update(&self, id: &u32) -> anyhow::Result<VideoData> {
        let mut transaction = get_pool().await.begin().await?;

        let maker = match &self.makers {
            Some(maker) => Some(Attr {
                id: maker.insert_maker(&mut transaction).await?,
                name: maker.0.clone(),
            }),
            None => None,
        };

        let maker_id = maker.as_ref().map(|maker| maker.id);

        let publisher = match &self.publisher {
            Some(publisher) => Some(Attr {
                id: publisher.insert_publisher(&mut transaction).await?,
                name: publisher.0.clone(),
            }),
            None => None,
        };

        let publisher_id = publisher.as_ref().map(|publisher| publisher.id);

        let series = match &self.series {
            Some(series) => Some(Attr {
                id: series.insert_series(&mut transaction).await?,
                name: series.0.clone(),
            }),
            None => None,
        };

        let series_id = series.as_ref().map(|series| series.id);

        let director = match &self.director {
            Some(director) => Some(Attr {
                id: director.insert_director(&mut transaction).await?,
                name: director.0.clone(),
            }),
            None => None,
        };

        let director_id = director.as_ref().map(|director| director.id);

        let mut tags = vec![];

        for tag in &self.tags {
            tags.push(Attr {
                id: tag.insert_tag(&id, &mut transaction).await?,
                name: tag.0.clone(),
            });
        }

        let mut actors = vec![];

        for actor in &self.actors {
            actors.push(Attr {
                id: actor.insert_actor(&id, &mut transaction).await?,
                name: actor.0.clone(),
            });
        }

        sqlx::query!(
            r#"
                update video
                set name = $1, title = $2, release_time = $3, duration = $4, maker_id = $5, publisher_id = $6, series_id = $7, director_id = $8,
                embedded_subtitles = $9, num_detail_images = $10, thumbnail_ratio = $11, is_retrieve = true, crawl_at = CURRENT_TIMESTAMP
                where id = $12
            "#,
            self.name,
            self.title,
            self.release_time,
            self.duration,
            maker_id,
            publisher_id,
            series_id,
            director_id,
            self.embedded_subtitles,
            self.num_detail_images,
            self.thumbnail_ratio,
            id
        )
            .execute(&mut *transaction)
            .await?;

        transaction.commit().await?;

        let data = VideoData {
            title: self.title.clone(),
            release_time: self.release_time.clone(),
            duration: self.duration,
            maker,
            publisher,
            series,
            director,
            tags,
            actors,
            num_detail_images: self.num_detail_images,
            thumbnail_ratio: self.thumbnail_ratio,
            embedded_subtitles: self.embedded_subtitles,
            subtitles: vec![],
        };
        Ok(data)
    }
}

impl AttrInterim {
    pub async fn insert_tag(
        &self,
        video_id: &u32,
        transaction: &mut Transaction<'_, Sqlite>,
    ) -> anyhow::Result<u32> {
        let id = match sqlx::query!(
            r#"
                insert or ignore into tag (name)
                values ($1)
                returning id as "id?:u32"
            "#,
            self.0
        )
        .fetch_optional(&mut **transaction)
        .await?
        {
            Some(row) => row.id.unwrap(),
            None => {
                sqlx::query!(
                    r#"
                        select id as "id!:u32"
                        from tag
                        where name = $1
                    "#,
                    self.0
                )
                .fetch_one(&mut **transaction)
                .await?
                .id
            }
        };

        sqlx::query!(
            r#"
                insert or ignore into video_tags (video_id, tag_id)
                values ($1, $2)
            "#,
            video_id,
            id
        )
        .execute(&mut **transaction)
        .await?;

        Ok(id)
    }

    pub async fn insert_actor(
        &self,
        video_id: &u32,
        transaction: &mut Transaction<'_, Sqlite>,
    ) -> anyhow::Result<u32> {
        let id = match sqlx::query!(
            r#"
                insert or ignore into actor (name)
                values ($1)
                returning id as "id?:u32"
            "#,
            self.0
        )
        .fetch_optional(&mut **transaction)
        .await?
        {
            Some(row) => row.id.unwrap(),
            None => {
                sqlx::query!(
                    r#"
                        select id as "id!:u32"
                        from actor
                        where name = $1
                    "#,
                    self.0
                )
                .fetch_one(&mut **transaction)
                .await?
                .id
            }
        };

        sqlx::query!(
            r#"
                insert or ignore into video_actors (video_id, actor_id)
                values ($1, $2)
            "#,
            video_id,
            id
        )
        .execute(&mut **transaction)
        .await?;

        Ok(id)
    }

    pub async fn insert_director(
        &self,
        transaction: &mut Transaction<'_, Sqlite>,
    ) -> anyhow::Result<u32> {
        let id = match sqlx::query!(
            r#"
                insert or ignore into director (name)
                values ($1)
                returning id as "id?:u32"
            "#,
            self.0
        )
        .fetch_optional(&mut **transaction)
        .await?
        {
            Some(row) => row.id.unwrap(),
            None => {
                sqlx::query!(
                    r#"
                        select id as "id!:u32"
                        from director
                        where name = $1
                    "#,
                    self.0
                )
                .fetch_one(&mut **transaction)
                .await?
                .id
            }
        };

        Ok(id)
    }

    pub async fn insert_maker(
        &self,
        transaction: &mut Transaction<'_, Sqlite>,
    ) -> anyhow::Result<u32> {
        let id = match sqlx::query!(
            r#"
                insert or ignore into maker (name)
                values ($1)
                returning id as "id?:u32"
            "#,
            self.0
        )
        .fetch_optional(&mut **transaction)
        .await?
        {
            Some(row) => row.id.unwrap(),
            None => {
                sqlx::query!(
                    r#"
                        select id as "id!:u32"
                        from maker
                        where name = $1
                    "#,
                    self.0
                )
                .fetch_one(&mut **transaction)
                .await?
                .id
            }
        };

        Ok(id)
    }

    pub async fn insert_publisher(
        &self,
        transaction: &mut Transaction<'_, Sqlite>,
    ) -> anyhow::Result<u32> {
        let id = match sqlx::query!(
            r#"
                insert or ignore into publisher (name)
                values ($1)
                returning id as "id?:u32"
            "#,
            self.0
        )
        .fetch_optional(&mut **transaction)
        .await?
        {
            Some(row) => row.id.unwrap(),
            None => {
                sqlx::query!(
                    r#"
                        select id as "id!:u32"
                        from publisher
                        where name = $1
                    "#,
                    self.0
                )
                .fetch_one(&mut **transaction)
                .await?
                .id
            }
        };

        Ok(id)
    }

    pub async fn insert_series(
        &self,
        transaction: &mut Transaction<'_, Sqlite>,
    ) -> anyhow::Result<u32> {
        let id = match sqlx::query!(
            r#"
                insert or ignore into series (name)
                values ($1)
                returning id as "id?:u32"
            "#,
            self.0
        )
        .fetch_optional(&mut **transaction)
        .await?
        {
            Some(row) => row.id.unwrap(),
            None => {
                sqlx::query!(
                    r#"
                        select id as "id!:u32"
                        from series
                        where name = $1
                    "#,
                    self.0
                )
                .fetch_one(&mut **transaction)
                .await?
                .id
            }
        };

        Ok(id)
    }
}

impl Attr {
    pub async fn query_all_actor() -> anyhow::Result<Vec<Self>> {
        let actors = sqlx::query_as!(
            Self,
            r#"
                select a.id as "id!:u32", name as "name!"
                from actor a,video_actors 
                where actor_id = a.id 
                group by a.id,name
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(actors)
    }

    pub async fn query_all_tag() -> anyhow::Result<Vec<Self>> {
        let tags = sqlx::query_as!(
            Self,
            r#"
                select a.id as "id!:u32", name as "name!"
                from tag a,video_tags 
                where tag_id = a.id 
                group by a.id,name
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(tags)
    }

    pub async fn query_all_maker() -> anyhow::Result<Vec<Self>> {
        let makers = sqlx::query_as!(
            Self,
            r#"
                select a.id as "id!:u32", a.name as "name!"
                from maker a,video 
                where maker_id = a.id 
                group by a.id,a.name
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(makers)
    }

    pub async fn query_all_publisher() -> anyhow::Result<Vec<Self>> {
        let publishers = sqlx::query_as!(
            Self,
            r#"
                select a.id as "id!:u32", a.name as "name!"
                from publisher a,video 
                where publisher_id = a.id 
                group by a.id,a.name
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(publishers)
    }

    pub async fn query_all_series() -> anyhow::Result<Vec<Self>> {
        let series = sqlx::query_as!(
            Self,
            r#"
                select a.id as "id!:u32", a.name as "name!"
                from series a,video 
                where series_id = a.id 
                group by a.id,a.name
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(series)
    }

    pub async fn query_all_director() -> anyhow::Result<Vec<Self>> {
        let directors = sqlx::query_as!(
            Self,
            r#"
                select a.id as "id!:u32", a.name as "name!"
                from director a,video 
                where director_id = a.id 
                group by a.id,a.name
            "#
        )
        .fetch_all(get_pool().await)
        .await?;

        Ok(directors)
    }
}
