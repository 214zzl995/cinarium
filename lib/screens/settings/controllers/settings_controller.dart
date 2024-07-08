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
      (_) {
        final conf = _taskConfig.copyWith(
          thread: thread,
        );

        _taskConfig = conf;
        notifyListeners();
      },
    );
  }

  void switchTemplateEnabled(int id) {
    final index = _crawlerTemplates.indexWhere((element) => element.id == id);
    final temp = _crawlerTemplates[index];
    final newTemp = temp.copyWith(enabled: !temp.enabled);
    _crawlerTemplates[index] = newTemp;

    switchCrawlerTemplateEnabled(id: id).then((_) {
      notifyListeners();
    });
  }

  void changeCrawlerTemplatePriority(List<(int, int)> prioritys) {
    for (final pair in prioritys) {
      final index = _crawlerTemplates.indexWhere((element) => element.id == pair.$1);
      final temp = _crawlerTemplates[index];
      final newTemp = temp.copyWith(priority: pair.$2);
      _crawlerTemplates[index] = newTemp;
    }

    changeCrawlerTemplatesPriority(prioritys: prioritys).then((_) {
      notifyListeners();
    });
  }

  init() async {
    _httpConfig = await getHttpConf();
    _taskConfig = await getTaskConf();
    _crawlerTemplates = getCrawlerTemplates();
    notifyListeners();
  }

  HttpConfig get httpConfig => _httpConfig;

  TaskConfig get taskConfig => _taskConfig;

  List<CrawlerTemplate> get crawlerTemps => _crawlerTemplates;
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

extension TaskConfigExt on TaskConfig {
  TaskConfig copyWith({String? tidyFolder, BigInt? thread}) {
    return TaskConfig(
      tidyFolder: tidyFolder == null
          ? this.tidyFolder
          : string2PathBuf(path: tidyFolder),
      thread: thread ?? this.thread,
    );
  }
}

extension CrawlerTemplateExt on CrawlerTemplate {
  CrawlerTemplate copyWith({
    int? id,
    String? baseUrl,
    String? jsonRaw,
    TemplateVideoDataInterim? template,
    int? priority,
    bool? enabled,
  }) {
    return CrawlerTemplate(
      id: id ?? this.id,
      baseUrl: baseUrl ?? this.baseUrl,
      jsonRaw: jsonRaw ?? this.jsonRaw,
      template: template ?? this.template,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
    );
  }
}
