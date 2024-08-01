use std::collections::HashMap;

use flutter_rust_bridge::frb;

use crate::model::{
    video::{Attr, RelatedAttr},
    HomeVideo,
};

#[allow(dead_code)]
pub enum FilterType {
    Actor(u32),
    Tag(u32),
    Maker(u32),
    Publisher(u32),
    Series(u32),
    Director(u32),
    Text(String),
}

#[derive(Debug)]
#[frb(opaque)]
pub struct HomeVideoData {
    videos: HashMap<u32, FilterHomeVideo>,
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
}

#[derive(Debug)]
struct FilterHomeVideo {
    video: HomeVideo,
    visible: bool,
}

impl FilterHomeVideo {
    fn new(video: HomeVideo) -> Self {
        Self {
            video,
            visible: true,
        }
    }

    fn show(&mut self) {
        self.visible = true;
    }

    fn hide(&mut self) {
        self.visible = false;
    }
}

impl HomeVideoData {
    #[allow(dead_code)]
    pub async fn new() -> anyhow::Result<Self> {
        let videos = HomeVideo::query_all().await?;
        let videos = videos
            .into_iter()
            .map(|v| (v.id, FilterHomeVideo::new(v)))
            .collect();

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
        })
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn filter_actor(&mut self, id: u32) {
        self.add_filter(FilterType::Actor(id));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn filter_tag(&mut self, id: u32) {
        self.add_filter(FilterType::Tag(id));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn filter_maker(&mut self, id: u32) {
        self.add_filter(FilterType::Maker(id));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn filter_publisher(&mut self, id: u32) {
        self.add_filter(FilterType::Publisher(id));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn filter_series(&mut self, id: u32) {
        self.add_filter(FilterType::Series(id));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn filter_director(&mut self, id: u32) {
        self.add_filter(FilterType::Director(id));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn filter_text(&mut self, text: String) {
        self.add_filter(FilterType::Text(text));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    fn add_filter(&mut self, filter_type: FilterType) {
        if self.maker_filter.is_empty()
            && self.publisher_filter.is_empty()
            && self.series_filter.is_empty()
            && self.director_filter.is_empty()
            && self.actor_filter.is_empty()
            && self.tag_filter.is_empty()
        {
            self.videos.iter_mut().for_each(|(_, v)| v.show());
        }
        match filter_type {
            FilterType::Actor(id) => {
                self.actor_filter.push(id);

                if let Some(video_ids) = self.actor_videos.get(&id) {
                    video_ids.iter().for_each(|&video_id| {
                        if let Some(video) = self.videos.get_mut(&video_id) {
                            video.show();
                        }
                    });
                };
            }
            FilterType::Tag(id) => {
                self.tag_filter.push(id);

                if let Some(video_ids) = self.tag_videos.get(&id) {
                    video_ids.iter().for_each(|&video_id| {
                        if let Some(video) = self.videos.get_mut(&video_id) {
                            video.show();
                        }
                    });
                };
            }
            FilterType::Maker(id) => {
                self.maker_filter.push(id);

                if let Some(video_ids) = self.maker_videos.get(&id) {
                    video_ids.iter().for_each(|&video_id| {
                        if let Some(video) = self.videos.get_mut(&video_id) {
                            video.show();
                        }
                    });
                };
            }
            FilterType::Publisher(id) => {
                self.publisher_filter.push(id);

                if let Some(video_ids) = self.publisher_videos.get(&id) {
                    video_ids.iter().for_each(|&video_id| {
                        if let Some(video) = self.videos.get_mut(&video_id) {
                            video.show();
                        }
                    });
                };
            }
            FilterType::Series(id) => {
                self.series_filter.push(id);

                if let Some(video_ids) = self.series_videos.get(&id) {
                    video_ids.iter().for_each(|&video_id| {
                        if let Some(video) = self.videos.get_mut(&video_id) {
                            video.show();
                        }
                    });
                };
            }
            FilterType::Director(id) => {
                self.director_filter.push(id);

                if let Some(video_ids) = self.director_videos.get(&id) {
                    video_ids.iter().for_each(|&video_id| {
                        if let Some(video) = self.videos.get_mut(&video_id) {
                            video.show();
                        }
                    });
                };
            }
            FilterType::Text(text) => {

                if text.is_empty() {
                    self.videos.iter_mut().for_each(|(_, v)| v.show());
                    return;
                }

                self.videos.iter_mut().for_each(|(_, v)| {
                    if v.video.title.contains(&text) {
                        v.show();
                    } else {
                        v.hide();
                    }
                });
            }
        }
    }

    #[allow(dead_code)]
    fn remove_filter(&mut self, filter_type: FilterType) {}

    #[allow(dead_code)]
    fn clear_filter(&mut self) {
        self.maker_filter.clear();
        self.publisher_filter.clear();
        self.series_filter.clear();
        self.director_filter.clear();
        self.actor_filter.clear();
        self.tag_filter.clear();
    }

    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn get_video(&self) -> anyhow::Result<Vec<HomeVideo>> {
        Ok(self
            .videos
            .values()
            .filter_map(|v| {
                if v.visible {
                    Some(v.video.clone())
                } else {
                    None
                }
            })
            .collect())
    }
}
