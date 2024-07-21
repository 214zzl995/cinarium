import 'dart:async';
import 'package:bridge/call_rust/model/video.dart';
import 'package:bridge/call_rust/native/home_api.dart';
import 'package:flutter/cupertino.dart';

class HomeController extends ChangeNotifier {
  late HomeVideoData _homeVideoData;

  bool _loading = false;

  bool _disposed = false;

  final Map<int, FilterValue> _actorFilter = {};
  final Map<int, FilterValue> _directorFilter = {};
  final Map<int, FilterValue> _tagFilter = {};
  final Map<int, FilterValue> _seriesFilter = {};
  final FilterSize _sizeFilter = FilterSize(BigInt.zero, BigInt.zero);
  final FilterDuration _durationFilter = FilterDuration(0, 0);
  final FilterReleaseTime _releaseTimeFilter =
      FilterReleaseTime(DateTime(1970), DateTime.now());

  String _textFilter = "";

  HomeController() {
    getHomeVideos();
  }

  Future<void> getHomeVideos() async {
    try {
      _loading = true;
      notifyListeners();
      _homeVideoData = await HomeVideoData.newInstance();

      for (var element in _homeVideoData.actor.entries) {
        _actorFilter[element.key] = FilterValue(element.value, false);
      }

      for (var element in _homeVideoData.director.entries) {
        _directorFilter[element.key] = FilterValue(element.value, false);
      }

      for (var element in _homeVideoData.tag.entries) {
        _tagFilter[element.key] = FilterValue(element.value, false);
      }

      for (var element in _homeVideoData.series.entries) {
        _seriesFilter[element.key] = FilterValue(element.value, false);
      }

      refreshMovList();
    } catch (e) {
      debugPrint("HomeController getList error");
      debugPrint(e.toString());
    } finally {
      _loading = false;
    }
  }

  void refreshMovList() {
    List<HomeVideo> filterList = [];

    if (_actorFilter.isNotEmpty) {
      filterList.addAll(_actorFilter.entries
          .where((element) => element.value.checked)
          .where((e) => _homeVideoData.videos[e.key] != null)
          .map((e) => _homeVideoData.videos[e.key]!));
    }

    if (_directorFilter.isNotEmpty) {
      filterList.addAll(_directorFilter.entries
          .where((element) => element.value.checked)
          .where((e) => _homeVideoData.videos[e.key] != null)
          .map((e) => _homeVideoData.videos[e.key]!));
    }

    if (_tagFilter.isNotEmpty) {
      filterList.addAll(_tagFilter.entries
          .where((element) => element.value.checked)
          .where((e) => _homeVideoData.videos[e.key] != null)
          .map((e) => _homeVideoData.videos[e.key]!));
    }

    if (_seriesFilter.isNotEmpty) {
      filterList.addAll(_seriesFilter.entries
          .where((element) => element.value.checked)
          .where((e) => _homeVideoData.videos[e.key] != null)
          .map((e) => _homeVideoData.videos[e.key]!));
    }

    if (filterList.isNotEmpty) {
      _homeVideoData.filterVideo = filterList.where((element) {
        if (_sizeFilter.min != 0 as BigInt || _sizeFilter.max != 0 as BigInt) {
          if (_sizeFilter.min == 0 as BigInt) {
            if (element.matedata.size >= _sizeFilter.max) {
              return false;
            }
          }

          if (_sizeFilter.max == 0 as BigInt) {
            if (element.matedata.size <= _sizeFilter.min) {
              return false;
            }
          }

          if (_sizeFilter.max != 0 as BigInt &&
              _sizeFilter.min != 0 as BigInt) {
            if (element.matedata.size <= _sizeFilter.min ||
                element.matedata.size >= _sizeFilter.max) {
              return false;
            }
          }
        }

        if (_durationFilter.min != 0 || _durationFilter.max != 0) {
          if (_durationFilter.min == 0) {
            if (element.duration >= _durationFilter.max) {
              return false;
            }
          }

          if (_durationFilter.max == 0) {
            if (element.duration <= _durationFilter.min) {
              return false;
            }
          }

          if (_durationFilter.max != 0 && _durationFilter.min != 0) {
            if (element.duration <= _durationFilter.min ||
                element.duration >= _durationFilter.max) {
              return false;
            }
          }
        }

        if (_textFilter.isNotEmpty) {
          if (!element.name.toLowerCase().contains(_textFilter.toLowerCase()) &&
              !element.title
                  .toLowerCase()
                  .contains(_textFilter.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    notifyListeners();
  }

  void addFilter(FilterType type, dynamic key, [bool value = true]) {
    switch (type) {
      case FilterType.actor:
        _actorFilter[key]!.checked = value;
        break;
      case FilterType.director:
        _directorFilter[key]!.checked = value;
        break;
      case FilterType.tag:
        _tagFilter[key]!.checked = value;
        break;
      case FilterType.series:
        _seriesFilter[key]!.checked = value;
        break;
      default:
        throw Exception("addFilter error");
    }
    refreshMovList();
  }

  void clearFilter(FilterType type) {
    switch (type) {
      case FilterType.actor:
        for (var element in _actorFilter.values) {
          element.checked = false;
        }
        break;
      case FilterType.director:
        for (var element in _directorFilter.values) {
          element.checked = false;
        }

        break;
      case FilterType.tag:
        for (var element in _tagFilter.values) {
          element.checked = false;
        }
        break;
      case FilterType.series:
        for (var element in _seriesFilter.values) {
          element.checked = false;
        }
        break;
      default:
        throw Exception("addFilter error");
    }
    refreshMovList();
  }

  void addTextFilter(String text) {
    _textFilter = text;
    refreshMovList();
  }

  void addSizeFilter(BigInt? min, BigInt? max) {
    if (min != null) {
      _sizeFilter.min = min;
    }
    if (max != null) {
      _sizeFilter.max = max;
    }
    refreshMovList();
  }

  void addDurationFilter(int? min, int? max) {
    if (min != null) {
      _durationFilter.min = min;
    }
    if (max != null) {
      _durationFilter.max = max;
    }
    refreshMovList();
  }

  void addReleaseTimeFilter(DateTime start, DateTime end) {
    _releaseTimeFilter.start = start;
    _releaseTimeFilter.end = end;
    refreshMovList();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  bool get loading => _loading;

  List<HomeVideo> get videoList => _homeVideoData.filterVideo;

  Map<int, FilterValue> get actorFilter => _actorFilter;

  Map<int, FilterValue> get directorFilter => _directorFilter;

  Map<int, FilterValue> get tagFilter => _tagFilter;

  Map<int, FilterValue> get seriesFilter => _seriesFilter;

  FilterSize get sizeFilter => _sizeFilter;

  FilterDuration get durationFilter => _durationFilter;

  FilterReleaseTime get releaseTimeFilter => _releaseTimeFilter;

  String get textFilter => _textFilter;
}

enum FilterType {
  actor,
  director,
  tag,
  series,
  duration,
  size,
  text,
  releaseTime
}

class FilterReleaseTime {
  final DateTime start;
  final DateTime end;

  const FilterReleaseTime(this.start, this.end);

  set start(DateTime value) {
    start = value;
  }

  set end(DateTime value) {
    end = value;
  }
}

class FilterSize {
  BigInt min;
  BigInt max;

  FilterSize(this.min, this.max);
}

class FilterDuration {
  int min;
  int max;

  FilterDuration(this.min, this.max);
}

class FilterValue {
  final String value;
  bool checked;

  FilterValue(this.value, this.checked);
}
