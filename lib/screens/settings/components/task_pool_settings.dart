import 'package:bridge/call_rust/native/system_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/settings/components/thread_field.dart';
import '../controllers/settings_controller.dart';
import 'crawler_temp_setting.dart';

class TaskPoolSetting extends StatelessWidget {
  const TaskPoolSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const ThreadField(),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildTidyFolder(context),
                    ],
                  ),
                ),
              ],
            )),
        const SizedBox(
          height: 20,
        ),
        Container(
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
            child: const Column(
              children: [CrawlerTempSetting()],
            )),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Row(
          children: [
            Icon(
              Icons.task_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'TaskPool',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildTidyFolder(BuildContext context) {
    return Selector<SettingsController, String>(selector: (_, settings) {
      return pathBuf2String(path: settings.taskConfig.tidyFolder);
    }, builder: (selectorContext, tidyFolder, __) {
      return Row(
        children: [
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Tidy Folder',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
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
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          openInExplorer(path: tidyFolder);
                        },
                        child: Text(
                          tidyFolder,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                    onPressed: () {
                      updateTaskTidyFolder();
                    },
                    child: const Icon(Icons.folder_open_outlined)),
              ),
            ],
          ),
        ],
      );
    });
  }
}
