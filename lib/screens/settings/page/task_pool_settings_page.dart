import 'package:flutter/material.dart';

import '../components/crawler_temp_setting.dart';
import '../components/task_pool_settings.dart';

class TaskPoolSettingsPage extends StatelessWidget {
  const TaskPoolSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const settingsPanel = [
      TaskPoolSetting(),
      CrawlerTempSetting()
    ];
    return ListView.builder(
      itemCount: settingsPanel.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: settingsPanel[index]);
      },
    );
  }
}
