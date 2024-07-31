import 'package:bridge/call_rust/app.dart';
import 'package:bridge/call_rust/native/system_api.dart';
import 'package:bridge/call_rust/task/crawler.dart';
import 'package:flutter/cupertino.dart';

class SettingsController with ChangeNotifier {
  late HttpConfig _httpConfig;

  late TaskConfig _taskConfig;

  late List<CrawlerTemplate> _crawlerTemplates;

  SettingsController() {
    init();
  }

  void changePort(int port) {
    updateHttpPort(port: port).then(
      (_) {
        _httpConfig = _httpConfig.copyWith(
          port: port,
        );
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void changeThread(BigInt thread) {
    updateTaskThread(thread: thread).then(
      (_) async {
        _taskConfig = await getTaskConf();
        notifyListeners();
      },
    );
  }

  void updateTidyFolder() {
    updateTaskTidyFolder().then(
      (_) async {
        _taskConfig = await getTaskConf();
        notifyListeners();
      },
    );
  }

  switchTemplateEnabled(int id) async {
    await switchCrawlerTemplateEnabled(id: id);
    final index = _crawlerTemplates.indexWhere((element) => element.id == id);
    final temp = _crawlerTemplates[index];
    final newTemp = temp.copyWith(enabled: !temp.enabled);
    _crawlerTemplates[index] = newTemp;
    notifyListeners();
  }

  void modelDisableChange(bool? value, int index) {
    switchTemplateEnabled(_crawlerTemplates[index].id);
  }

  void onTemplatesReorder(int oldIndex, int newIndex) {
    _crawlerTemplates = [...List.from(_crawlerTemplates)..removeAt(oldIndex)]
      ..insert(newIndex, _crawlerTemplates[oldIndex]);
    List.generate(
        _crawlerTemplates.length,
        (index) => _crawlerTemplates[index] =
            _crawlerTemplates[index].copyWith(priority: index));

    notifyListeners();

    changeCrawlerTemplatesPriority(
        prioritys: crawlerTemplates.map((e) => (e.id, e.priority)).toList());
  }

  init() async {
    _httpConfig = await getHttpConf();
    _taskConfig = await getTaskConf();
    _crawlerTemplates = getCrawlerTemplates();
    notifyListeners();
  }

  HttpConfig get httpConfig => _httpConfig;

  TaskConfig get taskConfig => _taskConfig;

  List<CrawlerTemplate> get crawlerTemplates => _crawlerTemplates;
}

extension HttpConfigsExt on HttpConfig {
  HttpConfig copyWith({
    int? port,
  }) {
    return HttpConfig(
      port: port ?? this.port,
    );
  }
}

extension CrawlerTemplateExt on CrawlerTemplate {
  CrawlerTemplate copyWith({
    int? id,
    String? baseUrl,
    String? searchUrl,
    String? jsonRaw,
    TemplateVideoDataInterim? template,
    int? priority,
    bool? enabled,
  }) {
    return CrawlerTemplate(
      id: id ?? this.id,
      baseUrl: baseUrl ?? this.baseUrl,
      searchUrl: searchUrl ?? this.searchUrl,
      jsonRaw: jsonRaw ?? this.jsonRaw,
      template: template ?? this.template,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
    );
  }
}