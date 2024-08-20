import 'package:flutter/material.dart';
import 'package:cinarium/screens/settings/components/brightness_setting.dart';
import 'package:cinarium/screens/settings/components/color_settings.dart';
import 'package:cinarium/screens/settings/components/mode_settings.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const settingsPanel = [
      BrightnessSetting(),
      ColorSettings(),
      ModeSetting(),
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
