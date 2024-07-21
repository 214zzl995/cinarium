import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_pages.dart';
import '../components/settings_navigation_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final route = GoRouter.of(context).location;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      //后续添加 顶部导航 滚动缩放
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 20),
            SettingNavigationItem(
              settingRoute: SettingRoutes.theme,
            ),
            SizedBox(width: 20),
            SettingNavigationItem(
              settingRoute: SettingRoutes.system,
            ),
            SizedBox(width: 20),
            SettingNavigationItem(
              settingRoute: SettingRoutes.taskPool,
            ),
            SizedBox(width: 20),
            SettingNavigationItem(
              settingRoute: SettingRoutes.httpFileServer,
            ),
          ],
        ),
        surfaceTintColor: Theme.of(context).colorScheme.background,
      ),
      body: child ?? Container(),
    );
  }
}
