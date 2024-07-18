-- Add down migration script here
delete from video_actors;
delete from video_tags;
delete from video;
delete from actor;
delete from publisher;
delete from director;
delete from maker;
delete from series;
delete from tag;
delete from source;
delete from task_msg;
delete from task;


drop table if exists maker;
drop table if exists series;
drop table if exists tag;
drop table if exists actor;
drop table if exists publisher;
drop table if exists director;
drop table if exists source;
drop table if exists task;
drop table if exists task_msg;
drop table if exists video_actors;
drop table if exists video_tags;
drop table if exists crawl_template;
drop table if exists video;