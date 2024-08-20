import 'package:flutter/material.dart';

import '../components/search_folder_settings.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const settingsPanel = [
      SearchFolderSettings(),
    ];
    return ListView.builder(
      itemCount: settingsPanel.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 4),
            child: settingsPanel[index]);
      },
    );
  }
}
