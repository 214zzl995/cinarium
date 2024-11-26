import 'package:bridge/call_rust/model/source.dart';
import 'package:cinarium/screens/retrieve/controllers/retrieve_controller.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../components/scroll_animator.dart';

class SettingsMonitorFolderPage extends StatelessWidget {
  const SettingsMonitorFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSearchFolderList(context),
        Positioned(
          bottom: 30,
          right: 40,
          width: 150,
          child: FloatingActionButton(
              onPressed: () {
                context.read<RetrieveController>().watchSource().then(
                  (value) {
                    if (value != null) {
                      showAboutDialog(
                          context: context,
                          applicationIcon: Icon(
                            Symbols.error,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            weight: 400,
                          ),
                          applicationName: 'Add Folder Failed',
                          applicationVersion: value,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'The folder you are trying to add is already in the list.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ]);
                    }
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.create_new_folder,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    weight: 400,
                  ),
                  const SizedBox(width: 10),
                  const Text('Add Folder'),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildSearchFolderList(BuildContext context) {
    return Selector<RetrieveController, bool>(
      selector: (_, value) => value.untreatedVideoDataLoading,
      builder: (context, untreatedVideoDataLoading, child) {
        if (untreatedVideoDataLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Selector<RetrieveController, List<Source>>(
          builder: (context, paths, child) => ScrollAnimator(
            scrollSpeed: 0.5,
            builder: (context, controller, physics) => ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
              controller: controller,
              physics: physics,
              children: paths
                  .map((source) => _buildFolderItem(context, source))
                  .toList(),
            ),
          ),
          selector: (_, settings) => settings.sources,
        );
      },
    );
    Selector<RetrieveController, List<Source>>(
      builder: (context, paths, child) => ScrollAnimator(
        scrollSpeed: 0.5,
        builder: (context, controller, physics) => ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
          controller: controller,
          physics: physics,
          children:
              paths.map((source) => _buildFolderItem(context, source)).toList(),
        ),
      ),
      selector: (_, settings) => settings.sources,
    );
  }

  Widget _buildFolderItem(BuildContext context, Source source) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 5),
      height: 65,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Symbols.folder,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  weight: 300,
                ),
                const SizedBox(width: 20),
                Text(source.path),
              ],
            ),
          ),
          TextButton.icon(
            label: Icon(
              Symbols.delete,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 18,
            ),
            onPressed: () => _showDeleteDialog(context, source),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Source source) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        ValueNotifier<bool> syncDelete = ValueNotifier<bool>(false);
        return AlertDialog(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Symbols.delete,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                weight: 700,
              ),
              const SizedBox(width: 10),
              const Text('Delete Search Folder'),
            ],
          ),
          contentPadding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          content: SizedBox(
            height: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 400),
                RichText(
                  text: TextSpan(
                    text: 'Are you sure you want to delete ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: source.path,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
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
                          syncDelete.value = !syncDelete.value;
                        },
                        child: const Text(
                          'Synchronized deletion index',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: syncDelete,
                      builder: (context, value, child) {
                        return Checkbox(
                          value: value,
                          onChanged: (value) {
                            syncDelete.value = value!;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context
                        .read<RetrieveController>()
                        .unwatchSource(source, syncDelete.value);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
