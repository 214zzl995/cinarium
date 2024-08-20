import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/theme.dart';

class BrightnessSetting extends StatelessWidget {
  const BrightnessSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey menuKey = GlobalKey();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Brightness',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Selector<CinariumTheme, ThemeMode>(
                  builder: (context, mode, _) => PopupMenuButton(
                    key: menuKey,
                    initialValue: mode,
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    constraints: const BoxConstraints(
                      minWidth: 100,
                    ),
                    enabled: false,
                    child: SizedBox(
                      width: 100,
                      child: TextButton(
                        onPressed: () {
                          final dynamic popupMenuState = menuKey.currentState;
                          popupMenuState.showButtonMenu();
                        },
                        child: Text(
                          mode.name,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ),
                    ),
                    onSelected: (val) {
                      final theme = context.read<CinariumTheme>();
                      theme.mode = val;
                      Brightness brightness;
                      if (val == ThemeMode.system) {
                        brightness = WidgetsBinding
                            .instance.platformDispatcher.platformBrightness;
                      } else {
                        brightness = val == ThemeMode.light
                            ? Brightness.light
                            : Brightness.dark;
                      }
                      theme.setEffect(theme.windowEffect, context,
                          brightness: brightness);
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<ThemeMode>>[
                      const PopupMenuItem<ThemeMode>(
                        height: 40,
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      const PopupMenuItem<ThemeMode>(
                        height: 40,
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                      const PopupMenuItem<ThemeMode>(
                        height: 40,
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                    ],
                  ),
                  selector: (context, theme) => theme.mode,
                )
              ],
            ))
          ],
        ),
      ]),
    );
  }
}

extension ThemeModeExt on ThemeMode {
  String get name {
    switch (this) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
