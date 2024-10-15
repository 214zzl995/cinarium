import 'package:cinarium/screens/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ThreadCountSetting extends StatelessWidget {
  const ThreadCountSetting({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> threadCount = ValueNotifier<int>(
        context.read<SettingsController>().taskConfig.thread);

    return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(6),
          ),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Icon(
                      Symbols.stacks,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Number of threads',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            SizedBox(
              width: 220,
              height: 30,
              child: ValueListenableBuilder<int>(
                valueListenable: threadCount,
                builder: (context, value, child) {
                  return Row(
                    children: [
                      SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5, disabledThumbRadius: 5),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 8),
                          ),
                          child: Slider(
                            value: value.toDouble(),
                            min: 1,
                            max: 8,
                            divisions: 7,
                            label: value.toString(),
                            onChanged: (value) {
                              threadCount.value = value.toInt();
                            },
                            onChangeEnd: (value) {
                              context
                                  .read<SettingsController>()
                                  .changeThread(value.toInt());
                            },
                          )),
                      Text(
                        value.toString(),
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ));
  }
}
