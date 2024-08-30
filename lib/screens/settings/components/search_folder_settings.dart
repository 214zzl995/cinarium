import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/settings/controllers/settings_controller.dart';

class SearchFolderSettings extends StatelessWidget {
  const SearchFolderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'SearchFolder',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                Expanded(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                          onPressed: () {
                            try {
                              context
                                  .read<SettingsController>()
                                  .addSearchFolder();
                            } catch (e) {
                              showAboutDialog(
                                  context: context,
                                  children: [Text(e.toString())]);
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.add_circle_outlined,
                                size: 12,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Add",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )),
                    )
                  ],
                ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            _buildSearchFolderList(context)
          ],
        ));
  }

  Widget _buildSearchFolderList(BuildContext context) {
    return Selector<SettingsController, List<String>>(
      builder: (context, paths, child) => Column(
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
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {

                        return AlertDialog(
                          title: const Text('Delete Search Folder'),
                          content:
                              Text('Are you sure you want to delete $path?'),
                          actions: [
                            Row(
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
      ),
      selector: (_, settings) => settings.searchFolders,
    );
  }
}
