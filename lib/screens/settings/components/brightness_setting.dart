import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../models/theme.dart';

class BrightnessSetting extends StatelessWidget {
  const BrightnessSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
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
              Symbols.light_mode,
              weight: 300,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'App theme',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Selector<CinariumTheme, ThemeMode>(
                  builder: (context, mode, _) =>
                      AnimatedToggleSwitch<ThemeMode?>.rolling(
                    allowUnlistedValues: true,
                    styleAnimationType: AnimationType.onHover,
                    current: mode,
                    values: ThemeMode.values,
                    borderWidth: 0,
                    height: 38,
                    indicatorSize: const Size.square(38),
                    style: ToggleStyle(
                      borderColor: Colors.transparent,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    onChanged: (val) {
                      final theme = context.read<CinariumTheme>();
                      theme.themeMode = val!;
                    },
                    iconBuilder: (ThemeMode? value, bool? foreground) =>
                        rollingIconBuilder(value, foreground, context),
                    customStyleBuilder: (context, local, global) {
                      final color = local.isValueListed
                          ? null
                          : Theme.of(context).colorScheme.error;
                      return ToggleStyle(
                          borderColor: color, indicatorColor: color);
                    },
                  ),
                  selector: (context, theme) => theme.themeMode,
                )
              ],
            ))
          ],
        ),
      ]),
    );
  }

  Widget rollingIconBuilder(
      ThemeMode? value, bool? foreground, BuildContext context) {
    IconData icon;
    switch (value!) {
      case ThemeMode.light:
        icon = Icons.sunny;
        break;
      case ThemeMode.dark:
        icon = Icons.nightlight;
        break;
      case ThemeMode.system:
        icon = Icons.brightness_auto;
        break;
    }
    return Icon(
      icon,
      size: 20,
      color: foreground!
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurface,
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
