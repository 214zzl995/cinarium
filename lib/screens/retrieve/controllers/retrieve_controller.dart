import 'package:bridge/call_rust/model/video.dart';
import 'package:bridge/call_rust/native.dart';
import 'package:bridge/call_rust/native/system_api.dart';
import 'package:bridge/call_rust/task.dart';
import 'package:flutter/cupertino.dart';

import 'package:bridge/call_rust/native/db_api.dart' as db_api;
import 'package:bridge/call_rust/native/task_api.dart' as task_api;

class RetrieveController with ChangeNotifier {
  List<UntreatedVideo> _untreatedVideos = [];

  bool _getVideoLoading = true;

  String _searchFlag = "";

  FileFilter _filterFlag = FileFilter.show;

  final Map<int, bool> _checkMap = {};

  late ListenerHandle _untreatedFileListenerHandle;
  late ListenerHandle _scanStorageListenerHandle;

  bool _untreatedFileHasChange = false;

  bool get untreatedFileHasChange => _untreatedFileHasChange;

  bool _scanStorageStatus = getScanStorageStatus();

  bool get scanStorageStatus => _scanStorageStatus;

  RetrieveController() {
    getUntreatedVideos();

    initListener();
  }

  initListener() async {
    _untreatedFileListenerHandle =
        await listenerUntreatedFile(dartCallback: untreatedFileHasChangeHandle);
    _scanStorageListenerHandle =
        await listenerScanStorage(dartCallback: scanStorageChangeHandle);
  }

  void untreatedFileHasChangeHandle() async {
    _untreatedFileHasChange = true;
    notifyListeners();
  }

  void scanStorageChangeHandle(bool val) async {
    _scanStorageStatus = val;
    notifyListeners();
  }

  void getUntreatedVideos() async {
    _checkMap.clear();
    final begin = DateTime.now().millisecondsSinceEpoch;
    _untreatedVideos = await db_api.getUntreatedVideos();
    final end = DateTime.now().millisecondsSinceEpoch;
    debugPrint("getUntreatedVideos cost time: ${end - begin}");
    for (var element in _untreatedVideos) {
      _checkMap[element.id] = false;
    }
    _getVideoLoading = false;
    _untreatedFileHasChange = false;
    notifyListeners();
  }

  void changeCrawlName(int id, String crawlName) async {
    int index = _untreatedVideos.indexWhere((element) => element.id == id);
    db_api.updateCrawlName(
        id: _untreatedVideos[index].id, crawlName: crawlName);
    _untreatedVideos[index] =
        _untreatedVideos[index].copyWith(crawlName: crawlName);
    notifyListeners();
  }

  void changeSearchFiles(String filterFlag) {
    _searchFlag = filterFlag;
    notifyListeners();
  }

  void changeFilterFiles([FileFilter? filterFlag, bool? cleanCheck]) {
    if (filterFlag == null) {
      if (_filterFlag == FileFilter.all) {
        _filterFlag = FileFilter.hide;
      } else if (_filterFlag == FileFilter.hide) {
        _filterFlag = FileFilter.show;
      } else {
        _filterFlag = FileFilter.all;
      }
    } else {
      _filterFlag = filterFlag;
    }

    if (cleanCheck ?? false) {
      _checkMap.forEach((key, value) {
        _checkMap[key] = false;
      });
    }

    notifyListeners();
  }

  void checkAllFiles(bool checkAll) {
    _checkMap.forEach((key, value) {
      _checkMap[key] = checkAll;
    });
    notifyListeners();
  }

  void checkFile(int id, [bool? check]) {
    if (check == null) {
      _checkMap[id] = !_checkMap[id]!;
    } else {
      _checkMap[id] = check;
    }
    notifyListeners();
  }

  void switchVideoHiddenWithCheck([bool? hidden]) {
    List<int> targetIds = _checkMap.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    switchVideosHidden(targetIds, hidden);

    for (var id in targetIds) {
      _checkMap[id] = false;
    }
    notifyListeners();
  }

  void switchVideosHidden(List<int> targetIds, [bool? hidden]) async {
    await db_api.switchVideosHidden(ids: targetIds);

    List<int> targetIndexes = targetIds
        .map((id) => _untreatedVideos.indexWhere((element) => element.id == id))
        .toList();

    for (var element in targetIndexes) {
      _untreatedVideos[element] = _untreatedVideos[element]
          .copyWith(isHidden: hidden ?? !_untreatedVideos[element].isHidden);
    }

    notifyListeners();
  }

  void insertionOfTasksCheck() {
    List<int> targetIds = _checkMap.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    insertionOfTasks(targetIds);
  }

  void insertionOfTasks(List<int> targetIds) async {
    final taskMetas = _untreatedVideos
        .where((element) => targetIds.contains(element.id))
        .map((e) => TaskMetadata(name: e.crawlName, videoId: e.id))
        .toList();

    await task_api.insertionOfTasks(tasks: taskMetas);

    _untreatedVideos.removeWhere((element) => targetIds.contains(element.id));
    _checkMap.removeWhere((key, value) => targetIds.contains(key));
    notifyListeners();
  }

  get taskVideos => _untreatedVideos;

  get getFileLoading => _getVideoLoading;

  get fileCount => showFiles.length;

  get checkMap => _checkMap;

  List<UntreatedVideo> get showFiles => _untreatedVideos.where((element) {
        if (_searchFlag.isEmpty) {
          if (_filterFlag == FileFilter.all) {
            return true;
          } else if (_filterFlag == FileFilter.show) {
            return !element.isHidden;
          } else {
            return element.isHidden;
          }
        }

        return ((element.isHidden && _filterFlag == FileFilter.show) ||
                _filterFlag == FileFilter.all ||
                (element.isHidden && _filterFlag == FileFilter.hide)) &&
            (element.metadata.filename
                    .toLowerCase()
                    .contains(_searchFlag.toLowerCase()) ||
                element.crawlName
                    .toLowerCase()
                    .contains(_searchFlag.toLowerCase()));
      }).toList();

  List<int> get checkFiles => _checkMap.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  bool? get checkAll {
    if (_checkMap.isEmpty) {
      return false;
    }

    final checkAllIn = _checkMap.values.every((bool element) => element);
    if (checkAllIn) {
      return true;
    } else {
      bool? unCheckAll = false;

      _checkMap.forEach((key, value) {
        if (value) {
          unCheckAll = null;
          return;
        }
      });
      return unCheckAll;
    }
  }

  @override
  void dispose() {
    _untreatedFileListenerHandle.cancel();
    _scanStorageListenerHandle.cancel();
    super.dispose();
  }

  get filterFlag => _filterFlag;

  get searchFlag => _searchFlag;
}

enum FileFilter { all, show, hide }

extension UntreatedVideoExt on UntreatedVideo {
  UntreatedVideo copyWith({
    int? id,
    String? crawlName,
    bool? isHidden,
    Metadata? metadata,
  }) {
    return UntreatedVideo(
      id: id ?? this.id,
      crawlName: crawlName ?? this.crawlName,
      isHidden: isHidden ?? this.isHidden,
      metadata: metadata ?? this.metadata,
    );
  }
}
