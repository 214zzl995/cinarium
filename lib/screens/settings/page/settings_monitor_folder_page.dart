import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../components/scroll_animator.dart';
import '../components/crawler_template_setting.dart';
import '../controllers/settings_controller.dart';

class SettingsMonitorFolderPage extends StatelessWidget {
  const SettingsMonitorFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Monitor Folders'),
          Expanded(child: _buildSearchFolderList(context))
        ],
      ),
    );
  }

  Widget _buildSearchFolderList(BuildContext context) {
    return Selector<SettingsController, List<String>>(
      builder: (context, paths, child) => ScrollAnimator(
      scrollSpeed: 0.5,
      builder: (context, controller, physics) => ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        controller: controller,
        physics: physics,
        children: [
          ...paths.map((path) => Container(
              key: ValueKey(path),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 5,
                bottom: 5,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(12),
                ),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(
                      path,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                    )),
                IconButton(
                  icon: Icon(
                    Symbols.delete,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        ValueNotifier<bool> syncDelete =
                        ValueNotifier<bool>(false);
                        return AlertDialog(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Symbols.delete,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                weight: 700,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Delete Search Folder')
                            ],
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20,
                          ),
                          content: SizedBox(
                              height: 100,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 400,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Are you sure you want to delete ',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: path,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            syncDelete.value =
                                            !syncDelete.value;
                                          },
                                          child: const Text(
                                              'Synchronized deletion index',
                                              style: TextStyle(
                                                fontSize: 12,
                                              )),
                                        ),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: syncDelete,
                                        builder: (context, value, child) {
                                          return Checkbox(
                                              value: value,
                                              onChanged: (value) {
                                                syncDelete.value = value!;
                                              });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              )),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // context.read<SettingsController>().removeSearchFolder(path);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    );
                    // context.read<SettingsController>().removeSearchFolder(path);
                  },
                )
              ])))
        ],
      )),
      selector: (_, settings) => settings.searchFolders,
    );
  }
}