import 'package:flutter/material.dart';

import '../../../components/scroll_animator.dart';
import '../components/app_theme_setting.dart';
import '../components/brightness_setting.dart';
import '../components/crawler_template_setting.dart';
import '../components/http_port_settings.dart';
import '../components/monitor_folder_setting.dart';
import '../components/thread_count_setting.dart';
import '../components/tidy_folder_settings.dart';

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollAnimator(
        scrollSpeed: 0.5,
        builder: (context, controller, physics) => ListView(
          physics: physics,
          controller: controller,
          padding:
          const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          children: [
            _buildMenuItemHeader(context, 'Appearance'),
            const BrightnessSetting(),
            const SizedBox(height: 3),
            const AppThemeSetting(),
            _buildMenuItemHeader(context, 'Http File Server'),
            const HttpPortSetting(),
            _buildMenuItemHeader(context, 'Advanced'),
            const MonitorFolderSetting(),
            _buildMenuItemHeader(context, 'Crawler'),
            const ThreadCountSetting(),
            const SizedBox(height: 3),
            const TidyFolderSetting(),
            const SizedBox(height: 3),
            const CrawlerTemplateSetting(),
          ],
        ));
  }

  Widget _buildMenuItemHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 3),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}