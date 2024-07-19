import 'package:flutter/material.dart';
import 'package:cinarium/screens/settings/components/http_settings.dart';

class HfsSettingsPage extends StatelessWidget {
  const HfsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const settingsPanel = [
      HfsSetting(),
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
