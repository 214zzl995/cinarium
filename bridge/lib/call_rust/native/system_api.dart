// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.5.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../app.dart';
import '../frb_generated.dart';
import '../lib.dart';
import '../model/source.dart';
import '../native.dart';
import '../task/crawler.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Future<void> initAppLog() =>
    RustLib.instance.api.crateNativeSystemApiInitAppLog();

Future<void> initCinariumConfig() =>
    RustLib.instance.api.crateNativeSystemApiInitCinariumConfig();

Future<void> initSourceNotify() =>
    RustLib.instance.api.crateNativeSystemApiInitSourceNotify();

Future<void> runWebApi() =>
    RustLib.instance.api.crateNativeSystemApiRunWebApi();

Future<void> stopWebApi() =>
    RustLib.instance.api.crateNativeSystemApiStopWebApi();

bool getHttpStatus() =>
    RustLib.instance.api.crateNativeSystemApiGetHttpStatus();

String getLocalIp() => RustLib.instance.api.crateNativeSystemApiGetLocalIp();

Future<TaskConfig> getTaskConf() =>
    RustLib.instance.api.crateNativeSystemApiGetTaskConf();

Future<HttpConfig> getHttpConf() =>
    RustLib.instance.api.crateNativeSystemApiGetHttpConf();

Future<void> updateHttpPort({required int port}) =>
    RustLib.instance.api.crateNativeSystemApiUpdateHttpPort(port: port);

Future<void> updateTaskThread({required int thread}) =>
    RustLib.instance.api.crateNativeSystemApiUpdateTaskThread(thread: thread);

Future<void> updateTaskTidyFolder({required String folder}) =>
    RustLib.instance.api
        .crateNativeSystemApiUpdateTaskTidyFolder(folder: folder);

Future<void> addSourceNotifyPath({required String path}) =>
    RustLib.instance.api.crateNativeSystemApiAddSourceNotifyPath(path: path);

Future<void> removeSourceNotifySource(
        {required Source source, required bool syncDelete}) =>
    RustLib.instance.api.crateNativeSystemApiRemoveSourceNotifySource(
        source: source, syncDelete: syncDelete);

Future<void> openInExplorer({required PathBuf path}) =>
    RustLib.instance.api.crateNativeSystemApiOpenInExplorer(path: path);

Future<void> openInExplorerByString({required String path}) =>
    RustLib.instance.api.crateNativeSystemApiOpenInExplorerByString(path: path);

Future<void> openInDefaultSoftware({required String path}) =>
    RustLib.instance.api.crateNativeSystemApiOpenInDefaultSoftware(path: path);

Future<void> changeCrawlerTemplatesPriority(
        {required List<(int, int)> prioritys}) =>
    RustLib.instance.api.crateNativeSystemApiChangeCrawlerTemplatesPriority(
        prioritys: prioritys);

Future<void> switchCrawlerTemplateEnabled({required int id}) =>
    RustLib.instance.api
        .crateNativeSystemApiSwitchCrawlerTemplateEnabled(id: id);

List<CrawlerTemplate> getCrawlerTemplates() =>
    RustLib.instance.api.crateNativeSystemApiGetCrawlerTemplates();

List<Source> getSourceNotifySources() =>
    RustLib.instance.api.crateNativeSystemApiGetSourceNotifySources();

Future<ListenerHandle> listenerHttpStatus(
        {required FutureOr<void> Function(bool) dartCallback}) =>
    RustLib.instance.api
        .crateNativeSystemApiListenerHttpStatus(dartCallback: dartCallback);

Future<ListenerHandle> listenerUntreatedFile(
        {required FutureOr<void> Function() dartCallback}) =>
    RustLib.instance.api
        .crateNativeSystemApiListenerUntreatedFile(dartCallback: dartCallback);

Future<ListenerHandle> listenerScanStorage(
        {required FutureOr<void> Function(bool) dartCallback}) =>
    RustLib.instance.api
        .crateNativeSystemApiListenerScanStorage(dartCallback: dartCallback);

bool getScanStorageStatus() =>
    RustLib.instance.api.crateNativeSystemApiGetScanStorageStatus();

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Template < VideoDataInterim >>>
abstract class TemplateVideoDataInterim implements RustOpaqueInterface {}
