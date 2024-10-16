import 'package:cinarium/screens/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ThreadCountSetting extends StatelessWidget {
  const ThreadCountSetting({super.key});

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
                          Selector<SettingsController, int>(
                            selector: (context, controller) =>
                                controller.taskConfig.thread,
                            builder: (context, thread, _) {
                              return Text(
                                'Number of threads: $thread',
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            },
                          ),
                          Text(
                            'The number of threads that can be run simultaneously',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            _buildEditButton(context),
          ],
        ));
  }

  Widget _buildEditButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (dialogContext) {
              ValueNotifier<int> threadCount = ValueNotifier<int>(
                  context.read<SettingsController>().taskConfig.thread);
              return AlertDialog(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number of threads',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text('The number of threads that can be run simultaneously',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        )),
                  ],
                ),
                content: ValueListenableBuilder<int>(
                  valueListenable: threadCount,
                  builder: (buildContext, value, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value.toString(),
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SliderTheme(
                            data: SliderTheme.of(buildContext).copyWith(
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                  disabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12),
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
                            )),
                      ],
                    );
                  },
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        context
                            .read<SettingsController>()
                            .changeThread(threadCount.value);
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('Save')),
                ],
              );
            });
      },
      child: const Icon(
        Symbols.open_in_new,
        size: 20,
      ),
    );
  }
}
