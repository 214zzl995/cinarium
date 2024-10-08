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
  final FilterReleaseTime _releaseTimeFilter =
      FilterReleaseTime(DateTime(1970), DateTime.now());

  double _filterPanelHeight = 400.0;

  int elapsedMilliseconds = 0;

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
    } catch (e) {
      debugPrint("HomeController getList error");
      debugPrint(e.toString());
    } finally {
      _loading = false;
    }

    notifyListeners();
  }

  void addFilter(FilterType type, dynamic key, [bool value = true]) {
    switch (type) {
      case FilterType.actor:
        _actorFilter[key]!.checked = value;
        _homeVideoData.filterActor(id: key);
        break;
      case FilterType.director:
        _directorFilter[key]!.checked = value;
        _homeVideoData.filterDirector(id: key);
        break;
      case FilterType.tag:
        _tagFilter[key]!.checked = value;
        _homeVideoData.filterTag(id: key);
        break;
      case FilterType.series:
        _seriesFilter[key]!.checked = value;
        _homeVideoData.filterSeries(id: key);
        break;
      default:
        throw Exception("addFilter error");
    }

    notifyListeners();
  }

  void clearFilter(FilterType type) {
    switch (type) {
      case FilterType.actor:
        for (var element in _actorFilter.values) {
          element.checked = false;
        }
        _homeVideoData.cleanActorFilter();
        break;
      case FilterType.director:
        for (var element in _directorFilter.values) {
          element.checked = false;
        }
        _homeVideoData.cleanDirectorFilter();

        break;
      case FilterType.tag:
        for (var element in _tagFilter.values) {
          element.checked = false;
        }
        _homeVideoData.cleanTagFilter();
        break;
      case FilterType.series:
        for (var element in _seriesFilter.values) {
          element.checked = false;
        }
        _homeVideoData.cleanSeriesFilter();
        break;
      default:
        throw Exception("addFilter error");
    }
    notifyListeners();
  }

  void addTextFilter(String text) {
    _homeVideoData.filterText(text: text);
    notifyListeners();
  }

  void addSizeFilter(BigInt? min, BigInt? max) {
    _homeVideoData.filterSize(min: min, max: max);
    notifyListeners();
  }

  void addDurationFilter(int? min, int? max) {
    _homeVideoData.filterDuration(min: min, max: max);
    notifyListeners();
  }

  void addReleaseTimeFilter(DateTime start, DateTime end) {
    _releaseTimeFilter.start = start;
    _releaseTimeFilter.end = end;
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

  double get filterPanelHeight => _filterPanelHeight;

  set filterPanelHeight(double value) {
    _filterPanelHeight = value;
    notifyListeners();
  }

  bool get loading => _loading;

  List<HomeVideo> get videoList => _homeVideoData.video;

  int get ts => _homeVideoData.ts;

  Map<int, FilterValue> get actorFilter => _actorFilter;

  Map<int, FilterValue> get directorFilter => _directorFilter;

  Map<int, FilterValue> get tagFilter => _tagFilter;

  Map<int, FilterValue> get seriesFilter => _seriesFilter;

  (BigInt?, BigInt?) get sizeFilter => _homeVideoData.sizeFilter;

  (int?, int?) get durationFilter => _homeVideoData.durationFilter;

  FilterReleaseTime get releaseTimeFilter => _releaseTimeFilter;

  String get textFilter => _homeVideoData.textFilter;

  HomeVideoData get homeVideoData => _homeVideoData;
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

class FilterValue {
  final String value;
  bool checked;

  FilterValue(this.value, this.checked);
}
