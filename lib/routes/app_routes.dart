part of 'app_pages.dart';

enum Routes {
  home(true),
  retrieve(true),
  hfs(true),
  pool(true),
  debug(true, isDebug: true),
  settings(false, initial: SettingRoutes.theme);

  const Routes(this.isTop, {this.isDebug = false, this.initial});

  final bool isTop;
  final bool isDebug;
  final dynamic initial;

  String get router => '/$name';
}

enum SettingRoutes {
  theme,
  httpFileServer,
  taskPool,
  system;

  const SettingRoutes();

  String get router => '/settings/$name';
}
