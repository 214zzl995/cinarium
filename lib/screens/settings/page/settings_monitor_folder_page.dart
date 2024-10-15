import 'package:flutter/material.dart';

import '../../../components/scroll_animator.dart';
import '../components/crawler_template_setting.dart';

class SettingsMonitorFolderPage extends StatelessWidget {
  const SettingsMonitorFolderPage({super.key});

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