import 'package:bridge/call_rust/file.dart';
import 'package:bridge/call_rust/model/source.dart';
import 'package:bridge/call_rust/model/video.dart';
import 'package:bridge/call_rust/native.dart';
import 'package:bridge/call_rust/native/system_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class RetrieveController with ChangeNotifier {
  final Map<int, bool> _checkMap = {};

  late ListenerHandle _untreatedFileListenerHandle;
  late ListenerHandle _scanStorageListenerHandle;

  late UntreatedVideoData _untreatedVideoData;

  bool _untreatedVideoDataLoading = true;

  bool _untreatedFileHasChange = false;

  bool get untreatedFileHasChange => _untreatedFileHasChange;

  bool _scanStorageStatus = getScanStorageStatus();

  bool get scanStorageStatus => _scanStorageStatus;

  RetrieveController() {
    UntreatedVideoData.newInstance().then((untreatedVideoData) async {
      _untreatedVideoData = untreatedVideoData;
      for (var element in await untreatedVideoData.getVideos()) {
        _checkMap[element.id] = false;
      }
      _untreatedVideoDataLoading = false;

      notifyListeners();
    });

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

  /*void changeCrawlName(int id, String crawlName) async {
    int index = _untreatedVideos.indexWhere((element) => element.id == id);
    db_api.updateCrawlName(
        id: _untreatedVideos[index].id, crawlName: crawlName);
    _untreatedVideos[index] =
        _untreatedVideos[index].copyWith(crawlName: crawlName);
    notifyListeners();
  }*/

  List<Source> get sources => _untreatedVideoData.sources;

  Future<String?> watchSource() async {
    final path = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
    );
    if (path != null) {
      String? err =
          await _untreatedVideoData.watchSourcePathStringF(path: path);
      if (err != null) {
        return err;
      } else {
        notifyListeners();
        return null;
      }
    } else {
      return null;
    }
  }

  void unwatchSource(Source source, bool syncDelete) async {
    await _untreatedVideoData.unwatchSourceF(
        source: source, syncDelete: syncDelete);
    notifyListeners();
  }

  set textFilter(String text) {
    _untreatedVideoData.textFilter = text;
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

    for (var id in targetIds) {
      _checkMap[id] = false;
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
    notifyListeners();
  }

  Future<List<UntreatedVideo>> get videos => _untreatedVideoDataLoading
      ? Future.value([])
      : _untreatedVideoData.getVideos();

  Future<BigInt> get videosSize => _untreatedVideoDataLoading
      ? Future.value(BigInt.zero)
      : _untreatedVideoData.getVideosSize();

  String get textFilter => _untreatedVideoData.textFilter;

  get untreatedVideoDataLoading => _untreatedVideoDataLoading;

  get checkMap => _checkMap;

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
    _untreatedVideoData.dispose();
    super.dispose();
  }
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
