import 'package:cinarium/screens/settings/components/thread_count_setting.dart';
import 'package:flutter/material.dart';
import '../../../components/scroll_animator.dart';
import '../components/brightness_setting.dart';
import '../components/app_theme_setting.dart';
import '../components/crawler_temp_setting.dart';
import '../components/http_settings.dart';
import '../components/monitor_folder_setting.dart';
import '../components/tidy_folder_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      //后续添加 顶部导航 滚动缩放
      body: ScrollAnimator(
          scrollSpeed: 0.5,
          builder: (context, controller, physics) => ListView(
                physics: physics,
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  _buildMenuItemHeader(context, 'Appearance'),
                  const BrightnessSetting(),
                  const SizedBox(height: 3),
                  const AppThemeSetting(),
                  _buildMenuItemHeader(context, 'Http File Server'),
                  const HttpSetting(),
                  _buildMenuItemHeader(context, 'Advanced'),
                  const MonitorFolderSetting(),
                  _buildMenuItemHeader(context, 'Crawler'),
                  const ThreadCountSetting(),
                  const SizedBox(height: 3),
                  const TidyFolderSetting(),
                  const SizedBox(height: 3),
                  const CrawlerTempSetting(),
                ],
              )),
    );
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
