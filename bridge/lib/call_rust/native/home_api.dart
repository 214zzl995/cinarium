// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.3.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import '../model/video.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `add_filter`, `clear_filter`, `hide_other_videos`, `is_hide`, `is_show`, `new`, `refresh_ts`, `remove_filter`, `reverse_map`, `show_other_videos`
// These types are ignored because they are not used by any `pub` functions: `FilterHomeVideo`, `FilterType`

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<HomeVideoData>>
abstract class HomeVideoData implements RustOpaqueInterface {
  Map<int, String> get actor;

  Uint32List get actorFilter;

  Map<int, String> get director;

  Uint32List get directorFilter;

  (int?, int?) get durationFilter;

  Map<int, String> get maker;

  Uint32List get makerFilter;

  Map<int, String> get publisher;

  Uint32List get publisherFilter;

  Map<int, String> get series;

  Uint32List get seriesFilter;

  (BigInt?, BigInt?) get sizeFilter;

  Map<int, String> get tag;

  Uint32List get tagFilter;

  String get textFilter;

  int get ts;

  Map<int, Uint32List> get videoDirectors;

  set actor(Map<int, String> actor);

  set actorFilter(Uint32List actorFilter);

  set director(Map<int, String> director);

  set directorFilter(Uint32List directorFilter);

  set durationFilter((int?, int?) durationFilter);

  set maker(Map<int, String> maker);

  set makerFilter(Uint32List makerFilter);

  set publisher(Map<int, String> publisher);

  set publisherFilter(Uint32List publisherFilter);

  set series(Map<int, String> series);

  set seriesFilter(Uint32List seriesFilter);

  set sizeFilter((BigInt?, BigInt?) sizeFilter);

  set tag(Map<int, String> tag);

  set tagFilter(Uint32List tagFilter);

  set textFilter(String textFilter);

  set ts(int ts);

  set videoDirectors(Map<int, Uint32List> videoDirectors);

  void cleanActorFilter();

  void cleanDirectorFilter();

  void cleanDurationFilter();

  void cleanMakerFilter();

  void cleanPublisherFilter();

  void cleanSeriesFilter();

  void cleanSizeFilter();

  void cleanTagFilter();

  void cleanTextFilter();

  void filterActor({required int id});

  void filterDirector({required int id});

  void filterDuration({int? min, int? max});

  void filterMaker({required int id});

  void filterPublisher({required int id});

  void filterSeries({required int id});

  void filterSize({BigInt? min, BigInt? max});

  void filterTag({required int id});

  void filterText({required String text});

  List<HomeVideo> get video;

  List<Attr> getVideoActors({required int videoId});

  List<Attr> getVideoDirectors({required int videoId});

  List<Attr> getVideoMakers({required int videoId});

  List<Attr> getVideoPublishers({required int videoId});

  List<Attr> getVideoSeries({required int videoId});

  List<Attr> getVideoTags({required int videoId});

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<HomeVideoData> newInstance() =>
      RustLib.instance.api.crateNativeHomeApiHomeVideoDataNew();
}
