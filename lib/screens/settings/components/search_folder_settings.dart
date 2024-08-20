import 'package:bridge/call_rust/task/crawler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
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
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            width: 1,
          ),
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
                            context
                                .read<SettingsController>()
                                .addSearchFolder();
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
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  width: 1,
                ),
              ),
              child: Row(children: [
                Text(
                  path,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                  ),
                )
              ])))
        ],
      ),
      selector: (_, settings) => settings.searchFolders,
    );
  }
}
