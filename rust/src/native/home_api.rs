use std::collections::HashMap;

use flutter_rust_bridge::frb;

use crate::model::{
    video::{Attr, RelatedAttr},
    HomeVideo,
};

#[allow(dead_code)]
pub enum FilterType {
    Actor,
    Tag,
    Maker,
    Publisher,
    Series,
    Director,
}

#[derive(Debug)]
#[frb(opaque)]
pub struct HomeVideoData {
    pub videos: HashMap<u32, HomeVideo>,
    pub actor: HashMap<u32, String>,
    pub tag: HashMap<u32, String>,
    pub maker: HashMap<u32, String>,
    pub publisher: HashMap<u32, String>,
    pub series: HashMap<u32, String>,
    pub director: HashMap<u32, String>,
    pub actor_videos: HashMap<u32, Vec<u32>>,
    pub tag_videos: HashMap<u32, Vec<u32>>,
    pub maker_videos: HashMap<u32, Vec<u32>>,
    pub publisher_videos: HashMap<u32, Vec<u32>>,
    pub series_videos: HashMap<u32, Vec<u32>>,
    pub director_videos: HashMap<u32, Vec<u32>>,
    pub maker_filter: Vec<u32>,
    pub publisher_filter: Vec<u32>,
    pub series_filter: Vec<u32>,
    pub director_filter: Vec<u32>,
    pub actor_filter: Vec<u32>,
    pub tag_filter: Vec<u32>,
    pub filter_video: Vec<HomeVideo>,
}

impl HomeVideoData {
    #[allow(dead_code)]
    pub async fn new() -> anyhow::Result<Self> {
        let videos = HomeVideo::query_all().await?;
        let filter_video = videos.clone();
        let videos = videos.into_iter().map(|v| (v.id, v)).collect();

        let actor = Attr::query_all_actor()
            .await?
            .into_iter()
            .map(|a| (a.id, a.name))
            .collect();
        let tag = Attr::query_all_tag()
            .await?
            .into_iter()
            .map(|t| (t.id, t.name))
            .collect();
        let maker = Attr::query_all_maker()
            .await?
            .into_iter()
            .map(|m| (m.id, m.name))
            .collect();
        let publisher = Attr::query_all_publisher()
            .await?
            .into_iter()
            .map(|p| (p.id, p.name))
            .collect();
        let series = Attr::query_all_series()
            .await?
            .into_iter()
            .map(|s| (s.id, s.name))
            .collect();
        let director = Attr::query_all_director()
            .await?
            .into_iter()
            .map(|d| (d.id, d.name))
            .collect();

        let actor_videos = RelatedAttr::query_all_video_actors()
            .await?
            .into_iter()
            .fold(HashMap::new(), |mut map, related_attr| {
                map.entry(related_attr.attr_id)
                    .or_insert_with(Vec::new)
                    .push(related_attr.video_id);
                map
            });

        let tag_videos = RelatedAttr::query_all_video_tags().await?.into_iter().fold(
            HashMap::new(),
            |mut map, related_attr| {
                map.entry(related_attr.attr_id)
                    .or_insert_with(Vec::new)
                    .push(related_attr.video_id);
                map
            },
        );

        let maker_videos = RelatedAttr::query_all_video_makers()
            .await?
            .into_iter()
            .fold(HashMap::new(), |mut map, related_attr| {
                map.entry(related_attr.attr_id)
                    .or_insert_with(Vec::new)
                    .push(related_attr.video_id);
                map
            });

        let publisher_videos = RelatedAttr::query_all_video_publishers()
            .await?
            .into_iter()
            .fold(HashMap::new(), |mut map, related_attr| {
                map.entry(related_attr.attr_id)
                    .or_insert_with(Vec::new)
                    .push(related_attr.video_id);
                map
            });

        let series_videos = RelatedAttr::query_all_video_series()
            .await?
            .into_iter()
            .fold(HashMap::new(), |mut map, related_attr| {
                map.entry(related_attr.attr_id)
                    .or_insert_with(Vec::new)
                    .push(related_attr.video_id);
                map
            });

        let director_videos = RelatedAttr::query_all_video_directors()
            .await?
            .into_iter()
            .fold(HashMap::new(), |mut map, related_attr| {
                map.entry(related_attr.attr_id)
                    .or_insert_with(Vec::new)
                    .push(related_attr.video_id);
                map
            });

        Ok(Self {
            videos,
            actor,
            tag,
            maker,
            publisher,
            series,
            director,
            actor_videos,
            tag_videos,
            maker_videos,
            publisher_videos,
            series_videos,
            director_videos,
            maker_filter: Vec::new(),
            publisher_filter: Vec::new(),
            series_filter: Vec::new(),
            director_filter: Vec::new(),
            actor_filter: Vec::new(),
            tag_filter: Vec::new(),
            filter_video,
        })
    }

    #[allow(dead_code)]
    fn add_filter(&mut self, filter_type: FilterType, id: u32) {
        if self.maker_filter.is_empty()
            && self.publisher_filter.is_empty()
            && self.series_filter.is_empty()
            && self.director_filter.is_empty()
            && self.actor_filter.is_empty()
            && self.tag_filter.is_empty()
        {
            self.filter_video.clear();
        }
        match filter_type {
            FilterType::Actor => {
                self.actor_filter.push(id);
            }
            FilterType::Tag => {
                self.tag_filter.push(id);
            }
            FilterType::Maker => {
                self.maker_filter.push(id);
            }
            FilterType::Publisher => {
                self.publisher_filter.push(id);
            }
            FilterType::Series => {
                self.series_filter.push(id);
            }
            FilterType::Director => {
                self.director_filter.push(id);
            }
        }
    }

    #[allow(dead_code)]
    fn remove_filter(&mut self, filter_type: FilterType, id: u32) {
        match filter_type {
            FilterType::Actor => {
                self.actor_filter.retain(|&x| x != id);
            }
            FilterType::Tag => {
                self.tag_filter.retain(|&x| x != id);
            }
            FilterType::Maker => {
                self.maker_filter.retain(|&x| x != id);
            }
            FilterType::Publisher => {
                self.publisher_filter.retain(|&x| x != id);
            }
            FilterType::Series => {
                self.series_filter.retain(|&x| x != id);
            }
            FilterType::Director => {
                self.director_filter.retain(|&x| x != id);
            }
        }

        if self.maker_filter.is_empty()
            && self.publisher_filter.is_empty()
            && self.series_filter.is_empty()
            && self.director_filter.is_empty()
            && self.actor_filter.is_empty()
            && self.tag_filter.is_empty()
        {
           
        }
    }

    #[allow(dead_code)]
    fn clear_filter(&mut self) {
        self.maker_filter.clear();
        self.publisher_filter.clear();
        self.series_filter.clear();
        self.director_filter.clear();
        self.actor_filter.clear();
        self.tag_filter.clear();
        
    }
}
