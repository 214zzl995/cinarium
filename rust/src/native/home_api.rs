use std::collections::{HashMap, HashSet};

use flutter_rust_bridge::frb;

use crate::model::{
    video::{Attr, RelatedAttr},
    HomeVideo,
};

#[derive(PartialEq, Eq)]
#[allow(dead_code)]
pub enum FilterType {
    Actor(u32),
    Tag(u32),
    Maker(u32),
    Publisher(u32),
    Series(u32),
    Director(u32),
    Text(String),
    Size(Option<u64>, Option<u64>),
    Duration(Option<u32>, Option<u32>),
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
    pub text_filter: String,
    pub size_filter: (Option<u64>, Option<u64>),
    pub duration_filter: (Option<u32>, Option<u32>),
    pub ts: u32,
}

#[derive(Debug)]
struct FilterHomeVideo {
    video: HomeVideo,
    actor_visible: bool,
    tag_visible: bool,
    maker_visible: bool,
    publisher_visible: bool,
    series_visible: bool,
    director_visible: bool,
    text_visible: bool,
    size_visible: bool,
    duration_visible: bool,
}

impl FilterHomeVideo {
    fn new(video: HomeVideo) -> Self {
        Self {
            video,
            actor_visible: true,
            tag_visible: true,
            maker_visible: true,
            publisher_visible: true,
            series_visible: true,
            director_visible: true,
            text_visible: true,
            size_visible: true,
            duration_visible: true,
        }
    }

    fn is_show(&self) -> bool {
        self.text_visible
            && self.size_visible
            && self.duration_visible
            && self.actor_visible
            && self.tag_visible
            && self.maker_visible
            && self.publisher_visible
            && self.series_visible
            && self.director_visible
    }

    #[allow(dead_code)]
    fn is_hide(&self) -> bool {
        !self.text_visible
            || !self.size_visible
            || !self.duration_visible
            || !self.actor_visible
            || !self.tag_visible
            || !self.maker_visible
            || !self.publisher_visible
            || !self.series_visible
            || !self.director_visible
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
            text_filter: String::new(),
            size_filter: (None, None),
            duration_filter: (None, None),
            ts: chrono::Local::now().timestamp_subsec_micros(),
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
    pub fn filter_size(&mut self, min: Option<u64>, max: Option<u64>) {
        self.add_filter(FilterType::Size(min, max));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn filter_duration(&mut self, min: Option<u32>, max: Option<u32>) {
        self.add_filter(FilterType::Duration(min, max));
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_actor_filter(&mut self) {
        self.actor_filter.clear();
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.actor_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_tag_filter(&mut self) {
        self.tag_filter.clear();
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.tag_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_maker_filter(&mut self) {
        self.maker_filter.clear();
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.maker_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_publisher_filter(&mut self) {
        self.publisher_filter.clear();
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.publisher_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_series_filter(&mut self) {
        self.series_filter.clear();
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.series_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_director_filter(&mut self) {
        self.director_filter.clear();
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.director_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_text_filter(&mut self) {
        self.text_filter.clear();
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.text_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_size_filter(&mut self) {
        self.size_filter = (None, None);
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.size_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    pub fn clean_duration_filter(&mut self) {
        self.duration_filter = (None, None);
        self.videos
            .iter_mut()
            .for_each(|(_, v)| v.duration_visible = true);
    }

    #[allow(dead_code)]
    #[frb(sync)]
    fn add_filter(&mut self, filter_type: FilterType) {
        match filter_type {
            FilterType::Actor(id) => {
                self.actor_filter.push(id);

                if let Some(video_ids) = self.actor_videos.clone().get(&id) {
                    self.hide_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Tag(id) => {
                self.tag_filter.push(id);

                if let Some(video_ids) = self.tag_videos.clone().get(&id) {
                    self.hide_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Maker(id) => {
                self.maker_filter.push(id);

                if let Some(video_ids) = self.maker_videos.clone().get(&id) {
                    self.hide_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Publisher(id) => {
                self.publisher_filter.push(id);

                if let Some(video_ids) = self.publisher_videos.clone().get(&id) {
                    self.hide_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Series(id) => {
                self.series_filter.push(id);

                if let Some(video_ids) = self.series_videos.clone().get(&id) {
                    self.hide_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Director(id) => {
                self.director_filter.push(id);

                if let Some(video_ids) = self.director_videos.clone().get(&id) {
                    self.hide_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Text(text) => {
                self.text_filter = text.clone();
                if text.is_empty() {
                    self.videos
                        .iter_mut()
                        .for_each(|(_, v)| v.text_visible = true);
                    return;
                }

                let text = text.trim().to_lowercase();

                self.videos.iter_mut().for_each(|(_, v)| {
                    if v.video.title.to_lowercase().contains(&text)
                        || v.video.name.to_lowercase().contains(&text)
                    {
                        v.text_visible = true;
                    } else {
                        v.text_visible = false;
                    }
                });
            }
            FilterType::Size(min, max) => {
                self.size_filter = (min, max);

                self.videos.iter_mut().for_each(|(_, v)| {
                    if v.video.matedata.size >= min.unwrap_or(0)
                        && v.video.matedata.size <= max.unwrap_or(u64::MAX)
                    {
                        v.size_visible = true;
                    } else {
                        v.size_visible = false;
                    }
                });
            }
            FilterType::Duration(min, max) => {
                self.duration_filter = (min, max);

                self.videos.iter_mut().for_each(|(_, v)| {
                    if v.video.duration >= min.unwrap_or(0)
                        && v.video.duration <= max.unwrap_or(u32::MAX)
                    {
                        v.duration_visible = true;
                    } else {
                        v.duration_visible = false;
                    }
                });
            }
        }
        self.refresh_ts();
    }

    #[allow(dead_code)]
    fn remove_filter(&mut self, filter_type: FilterType) {
        match filter_type {
            FilterType::Actor(id) => {
                self.actor_filter.retain(|&x| x != id);

                if let Some(video_ids) = self.actor_videos.clone().get(&id) {
                    self.show_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Tag(id) => {
                self.tag_filter.retain(|&x| x != id);

                if let Some(video_ids) = self.tag_videos.clone().get(&id) {
                    self.show_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Maker(id) => {
                self.maker_filter.retain(|&x| x != id);
                if let Some(video_ids) = self.maker_videos.clone().get(&id) {
                    self.show_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Publisher(id) => {
                self.publisher_filter.retain(|&x| x != id);
                if let Some(video_ids) = self.publisher_videos.clone().get(&id) {
                    self.show_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Series(id) => {
                self.series_filter.retain(|&x| x != id);
                if let Some(video_ids) = self.series_videos.clone().get(&id) {
                    self.show_other_videos(video_ids, &filter_type);
                };
            }
            FilterType::Director(id) => {
                self.director_filter.retain(|&x| x != id);
                if let Some(video_ids) = self.director_videos.clone().get(&id) {
                    self.show_other_videos(video_ids, &filter_type);
                };
            }
            _ => {}
        }
        self.refresh_ts();
    }

    #[allow(dead_code)]
    fn clear_filter(&mut self) {
        self.maker_filter.clear();
        self.publisher_filter.clear();
        self.series_filter.clear();
        self.director_filter.clear();
        self.actor_filter.clear();
        self.tag_filter.clear();
        self.text_filter.clear();
        self.size_filter = (None, None);
        self.duration_filter = (None, None);
    }

    #[frb(sync, getter)]
    #[allow(dead_code)]
    pub fn get_video(&self) -> anyhow::Result<Vec<HomeVideo>> {
        Ok(self
            .videos
            .values()
            .filter_map(|v| {
                if v.is_show() {
                    Some(v.video.clone())
                } else {
                    None
                }
            })
            .collect())
    }
    #[allow(dead_code)]
    fn hide_other_videos(&mut self, video_ids: &Vec<u32>, filter_type: &FilterType) {
        let video_ids: HashSet<u32> = video_ids.iter().cloned().collect();
        let show_ids: HashSet<u32> = self
            .videos
            .iter()
            .filter_map(|(id, v)| if v.is_show() { Some(*id) } else { None })
            .collect();

        let hide_ids: HashSet<u32> = video_ids.difference(&show_ids).cloned().collect();

        hide_ids.iter().for_each(|&video_id| {
            if let Some(video) = self.videos.get_mut(&video_id) {
                match filter_type {
                    FilterType::Actor(_) => video.actor_visible = false,
                    FilterType::Tag(_) => video.tag_visible = false,
                    FilterType::Maker(_) => video.maker_visible = false,
                    FilterType::Publisher(_) => video.publisher_visible = false,
                    FilterType::Series(_) => video.series_visible = false,
                    FilterType::Director(_) => video.director_visible = false,
                    _ => {}
                };
            }
        });
    }
    #[allow(dead_code)]
    fn show_other_videos(&mut self, video_ids: &Vec<u32>, filter_type: &FilterType) {
        let video_ids: HashSet<u32> = video_ids.iter().cloned().collect();
        let show_ids: HashSet<u32> = self
            .videos
            .iter()
            .filter_map(|(id, v)| if v.is_show() { Some(*id) } else { None })
            .collect();

        let hide_ids: HashSet<u32> = video_ids.difference(&show_ids).cloned().collect();

        hide_ids.iter().for_each(|&video_id| {
            if let Some(video) = self.videos.get_mut(&video_id) {
                match filter_type {
                    FilterType::Actor(_) => video.actor_visible = true,
                    FilterType::Tag(_) => video.tag_visible = true,
                    FilterType::Maker(_) => video.maker_visible = true,
                    FilterType::Publisher(_) => video.publisher_visible = true,
                    FilterType::Series(_) => video.series_visible = true,
                    FilterType::Director(_) => video.director_visible = true,
                    _ => {}
                };
            }
        });
    }

    #[allow(dead_code)]
    fn refresh_ts(&mut self) {
        self.ts = chrono::Local::now().timestamp_subsec_micros();
    }
}
