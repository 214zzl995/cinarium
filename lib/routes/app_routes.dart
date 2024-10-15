part of 'app_pages.dart';

enum Routes {
  home(true),
  retrieve(true),
  http(true),
  pool(true),
  debug(true, isDebug: true),
  settings(false);

  const Routes(this.isTop, {this.isDebug = false});

  final bool isTop;
  final bool isDebug;

  String get router => '/$name';
}

enum SettingsRoutes {
  main,
  monitorFolder(title: 'Monitor Folder'),
  crawlerTemplate(title: 'Crawler Template'),;

  const SettingsRoutes({this.title = ''});

  final String title;

  String get router => name;

  String get jumpRouter => '/settings/$name';
}
