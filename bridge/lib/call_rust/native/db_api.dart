// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import '../model/video.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Future<void> initDb() => RustLib.instance.api.crateNativeDbApiInitDb();

Future<List<HomeVideo>> getHomeVideos() =>
    RustLib.instance.api.crateNativeDbApiGetHomeVideos();

Future<List<UntreatedVideo>> getTaskVideos() =>
    RustLib.instance.api.crateNativeDbApiGetTaskVideos();

Future<void> switchVideosHidden({required List<int> ids}) =>
    RustLib.instance.api.crateNativeDbApiSwitchVideosHidden(ids: ids);

Future<void> updateCrawlName({required int id, required String crawlName}) =>
    RustLib.instance.api
        .crateNativeDbApiUpdateCrawlName(id: id, crawlName: crawlName);