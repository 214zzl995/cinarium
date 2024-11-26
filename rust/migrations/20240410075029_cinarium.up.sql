-- add up migration script here
create table video
(
    id                 integer primary key,
    hash               text not null unique,
    name               text,
    title              text,
    filename           text not null,
    crawl_name         text,
    path               text,
    size               integer,
    extension          text,
    release_time       text,
    duration           integer,
    publisher_id       integer,
    maker_id           integer,
    series_id          integer,
    director_id        integer,
    source_id          integer,
    is_retrieve        boolean  default false,
    is_hidden          boolean  default false,
    embedded_subtitles boolean  default false,
    num_detail_images  integer  default 0,
    thumbnail_ratio    real,
    is_new             boolean  default true,
    is_deleted         boolean  default false,
    crawl_at           text,
    created_at         datetime default current_timestamp,
    updated_at         datetime default current_timestamp,
    foreign key ( publisher_id ) references publisher ( id ) on delete no action,
    foreign key ( maker_id ) references maker ( id ) on delete no action,
    foreign key ( series_id ) references series ( id ) on delete no action,
    foreign key ( director_id ) references director ( id ) on delete no action,
    foreign key ( source_id ) references source ( id ) on delete no action,
    unique ( path, filename, extension, is_deleted )
);

create index idx_video_source_id on video ( source_id );

create table actor
(
    id   integer primary key,
    name text unique
);

create table publisher
(
    id   integer primary key,
    name text unique
);

create table director
(
    id   integer primary key,
    name text unique
);

create table maker
(
    id   integer primary key,
    name text unique
);

create table series
(
    id   integer primary key,
    name text unique
);

create table tag
(
    id   integer primary key,
    name text unique
);

create table video_actors
(
    id       integer primary key,
    video_id integer,
    actor_id integer,
    foreign key ( video_id ) references video ( id ) on delete cascade,
    foreign key ( actor_id ) references actor ( id ) on delete cascade,
    unique ( video_id, actor_id )
);

create table video_tags
(
    id       integer primary key,
    video_id integer,
    tag_id   integer,
    foreign key ( video_id ) references video ( id ) on delete cascade,
    foreign key ( tag_id ) references tag ( id ) on delete cascade,
    unique ( video_id, tag_id )
);

create table source
(
    id   integer primary key,
    path text
);

create table task
(
    id       text primary key not null,
    video_id integer          not null,
    status   integer default 0,
    foreign key ( video_id ) references video ( id ) on delete cascade
);

create table task_msg
(
    id      integer primary key,
    task_id text not null,
    msg     text,
    foreign key ( task_id ) references task ( id ) on delete cascade
);

create table crawl_template
(
    id         integer primary key,
    json_raw   text,
    base_url   text,
    search_url text,
    priority   integer default 0,
    enabled    boolean default true
);

create trigger if not exists update_video_updated_at
    after update
    on video
    for each row
begin
    update video set updated_at = current_timestamp where id = new.id;
end;

insert into crawl_template (id,
                            json_raw,
                            base_url,
                            search_url,
                            priority,
                            enabled)
values (1,
        '{
        "nodes": {
            "main": {
                "script": "selector(''.movie-list'')",
                "children": {
                    "match_div": {
                        "script": "selector(''.video-title>strong'').val().delete(''-'').uppercase().equals(${crawl_name}).parent(2)",
                        "children": {
                            "title": {
                                "script": "attr(''title'')"
                            },
                            "detail_url": {
                                "script": "attr(''href'').insert(0,${base_url})",
                                "request": true,
                                "children": {
                                    "main_image": {
                                        "script": "selector(''.video-meta-panel>div>div.column.column-video-cover>a>img'').attr(''src'')"
                                    },
                                    "detail_imgs": {
                                        "script": "selector(''.video-detail>.columns>.column>.message.video-panel>.message-body>.tile-images.preview-images>.tile-item'').attr(''href'')"
                                    },
                                    "detail_title": {
                                        "script": "selector(''.video-detail .current-title'').val()"
                                    },
                                    "detail": {
                                        "script": "selector(''.panel-block>strong'')",
                                        "children": {
                                            "series": {
                                                "script": "val().delete('' '').equals(''系列:'').next().val()"
                                            },
                                            "tags": {
                                                "script": "val().delete('' '').equals(''類別:'').next().selector(''a'').val()"
                                            },
                                            "actors": {
                                                "script": "val().delete('' '').equals(''演員:'').next().selector(''.female'').prev().val()"
                                            },
                                            "duration": {
                                                "script": "val().delete('' '').equals(''時長:'').next().val().delete('' 分鍾'')"
                                            },
                                            "publisher": {
                                                "script": "val().delete('' '').equals(''發行:'').next().val()"
                                            },
                                            "release_time": {
                                                "script": "val().delete('' '').equals(''日期:'').next().val()"
                                            },
                                            "makers": {
                                                "script": "val().delete('' '').equals(''片商:'').next().val()"
                                            },
                                            "director": {
                                                "script": "val().delete('' '').equals(''導演:'').next().val()"
                                            }
                                        }
                                    }
                                }
                            },
                            "name": {
                                "script": "selector(''.video-title>strong'').val()"
                            },
                            "thumbnail": {
                                "script": "selector(''img'').attr(''src'')"
                            }
                        }
                    }
                }
            }
        }
    }',
        'https://www.javdb.com',
        '${base_url}/search?q=${crawl_name}&f=all',
        0,
        1);
