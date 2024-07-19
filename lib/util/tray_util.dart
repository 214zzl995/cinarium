import 'dart:async';
import 'dart:io';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class TrayUtil {
  static String getTrayImagePath(String imageName) {
    return Platform.isWindows
        ? 'assets/tray/$imageName.ico'
        : 'assets/tray/$imageName.png';
  }

  static String getImagePath(String imageName) {
    return Platform.isWindows
        ? 'assets/tray/$imageName.bmp'
        : 'assets/tray/$imageName.png';
  }

  static Future<void> initSystemTray() async {
    final systemTray = SystemTray();
    final menu = Menu();
    Timer? timer;
    bool toogleTrayIcon = true;

    await systemTray.initSystemTray(
        iconPath: TrayUtil.getTrayImagePath('app_icon'));
    systemTray.setTitle("system tray");
    systemTray.setToolTip("How to use system tray with Flutter");

    //注册托盘图标点击事件
    systemTray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows
            ? await windowManager.show()
            : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows
            ? systemTray.popUpContextMenu()
            : await windowManager.show();
      }
    });

    await menu.buildFrom(
      [
        MenuItemLabel(
            label: 'Show', onClicked: (menuItem) => windowManager.show()),
        MenuItemLabel(
            label: 'Hide', onClicked: (menuItem) => windowManager.hide()),
        MenuItemLabel(
            label: 'Close', onClicked: (menuItem) => windowManager.close()),
        MenuItemLabel(
          label: 'Start flash tray icon',
          onClicked: (menuItem) {
            ///判断定时器是否为空，如果为空则创建一个定时器，否则不创建
            if (timer == null) {
              menuItem.setLabel("Stop flash tray icon");
              timer = Timer.periodic(
                const Duration(milliseconds: 500),
                (timer) {
                  toogleTrayIcon = !toogleTrayIcon;
                  systemTray.setImage(toogleTrayIcon
                      ? ""
                      : TrayUtil.getTrayImagePath('app_icon'));
                },
              );
            } else {
              menuItem.setLabel("Start flash tray icon");
              timer?.cancel();
              timer = null;
              systemTray.setImage(TrayUtil.getTrayImagePath('app_icon'));
            }
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
            label: 'Exit', onClicked: (menuItem) => windowManager.close()),
      ],
    );
    systemTray.setContextMenu(menu);
  }
}
