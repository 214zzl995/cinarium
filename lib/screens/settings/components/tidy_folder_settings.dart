import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

class TidyFolderSetting extends StatelessWidget {
  const TidyFolderSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    context.read<SettingsController>().updateTidyFolder();
                  },
                  child: _buildTidyFolder(context))),
        ),
      ],
    );
  }

  Widget _buildTidyFolder(BuildContext context) {
    return Selector<SettingsController, String>(
        selector: (_, settings) => settings.taskConfig.tidyFolder,
        builder: (selectorContext, tidyFolder, __) {
          return Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Symbols.folder,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        weight: 300,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Tidy Folder',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ),
                    ],
                  )),
              Row(
                children: [
                  AnimatedSwitcher(
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        key: ValueKey(tidyFolder),
                        width: 200,
                        child: Text(
                          tidyFolder,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      )),
                ],
              ),
            ],
          );
        });
  }
}
