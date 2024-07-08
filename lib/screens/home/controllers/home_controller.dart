import 'dart:async';
import 'package:bridge/call_rust/model/video.dart';
import 'package:bridge/call_rust/native/db_api.dart';
import 'package:flutter/cupertino.dart';


class HomeController extends ChangeNotifier {
  late var count = 0;

  List<HomeVideo> _dbVideoList = [];

  List<HomeVideo> _movList = [];

  bool _loading = false;

  bool _disposed = false;

  final Map<int, FilterValue> _actorFilter = {};
  final Map<int, FilterValue> _directorFilter = {};
  final Map<int, FilterValue> _tagFilter = {};
  final Map<int, FilterValue> _seriesFilter = {};
  final FilterSizeWithDuration _sizeFilter = FilterSizeWithDuration(0, 0);
  final FilterSizeWithDuration _durationFilter = FilterSizeWithDuration(0, 0);
  final FilterReleaseTime _releaseTimeFilter =
      FilterReleaseTime(DateTime(1970), DateTime.now());

  String _textFilter = "";

  HomeController() {
    getNativeList();
  }

  void increment() {
    count++;
    notifyListeners();
  }

  Future<void> getNativeList() async {
    try {
      _loading = true;
      notifyListeners();
      _dbVideoList = await getHomeVideos();
      for (var video in _dbVideoList) {
        for (var element in video.actors) {
          final key = element.id;
          if (!_actorFilter.containsKey(key)) {
            _actorFilter[key] = FilterValue(element, false);
          }
        }
        for (var element in video.tags) {
          final key = element.id;
          if (!_tagFilter.containsKey(key)) {
            _tagFilter[key] = FilterValue(element, false);
          }
        }
        if (video.series != null) {
          final key = video.series!.id;
          if (!_seriesFilter.containsKey(key)) {
            _seriesFilter[key] = FilterValue(video.series!, false);
          }
        }
        if (video.director != null) {
          final key = video.director!.id;
          if (!_directorFilter.containsKey(key)) {
            _directorFilter[key] = FilterValue(video.director!, false);
          }
        }
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
    _movList = _dbVideoList.where((element) {
      if (_actorFilter.values.any((element) => element.checked)) {
        if (element.actors
            .every((element) => !_actorFilter[element.id]!.checked)) {
          return false;
        }
      }

      if (_directorFilter.values.any((element) => element.checked)) {
        if (element.director == null) return false;
        if (!_directorFilter[element.director!.id]!.checked) {
          return false;
        }
      }

      if (_tagFilter.values.any((element) => element.checked)) {
        if (element.tags.every((element) => !_tagFilter[element.id]!.checked)) {
          return false;
        }
      }

      if (_seriesFilter.values.any((element) => element.checked)) {
        if (element.series == null) return false;
        if (!_seriesFilter[element.series!.id]!.checked) {
          return false;
        }
      }

      if (_sizeFilter.min != 0 || _sizeFilter.max != 0) {
        if (_sizeFilter.min == 0) {
          if (element.size >= _sizeFilter.max) {
            return false;
          }
        }

        if (_sizeFilter.max == 0) {
          if (element.size <= _sizeFilter.min) {
            return false;
          }
        }

        if (_sizeFilter.max != 0 && _sizeFilter.min != 0) {
          if (element.size <= _sizeFilter.min ||
              element.size >= _sizeFilter.max) {
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
            !element.title.toLowerCase().contains(_textFilter.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

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

  void addSizeFilter(int? min, int? max) {
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

  List<Smov> get movList => _movList;

  Map<int, FilterValue> get actorFilter => _actorFilter;

  Map<int, FilterValue> get directorFilter => _directorFilter;

  Map<int, FilterValue> get tagFilter => _tagFilter;

  Map<int, FilterValue> get seriesFilter => _seriesFilter;

  FilterSizeWithDuration get sizeFilter => _sizeFilter;

  FilterSizeWithDuration get durationFilter => _durationFilter;

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

class FilterSizeWithDuration {
  int min;
  int max;

  FilterSizeWithDuration(this.min, this.max);
}

class FilterValue {
  final SmovAttr value;
  bool checked;

  FilterValue(this.value, this.checked);

  @override
  String toString() {
    return 'FilterValue{value.name: ${value.name}, checked: $checked}';
  }
}
