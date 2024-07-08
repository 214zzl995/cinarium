import 'package:flutter/material.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const settingsPanel = [
      Text('TidyFolder'),
      Text('SearchFolder'),
      Chip(
        label: Text('中文'),
      ),
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
