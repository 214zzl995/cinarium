import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

class TidyFolderSetting extends StatelessWidget {
  const TidyFolderSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            context.read<SettingsController>().updateTidyFolder();
          },
          child: Container(
              height: 70,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(6),
                ),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.5),
                  width: 1,
                ),
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              child: _buildTidyFolder(context)),
        ));
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tidy Folder',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              tidyFolder,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              TextButton(
                onPressed: () {
                  context.read<SettingsController>().updateTidyFolder();
                },
                child: const Icon(
                  Symbols.open_in_new,
                  size: 20,
                ),
              ),
            ],
          );
        });
  }
}
