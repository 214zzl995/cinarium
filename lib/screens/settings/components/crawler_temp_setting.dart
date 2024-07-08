import 'package:bridge/call_rust/task/crawler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:cinarium/screens/settings/controllers/settings_controller.dart';

class CrawlerTempSetting extends StatefulWidget {
  const CrawlerTempSetting({super.key});

  @override
  CrawlerTempSettingState createState() => CrawlerTempSettingState();
}

class CrawlerTempSettingState extends State<CrawlerTempSetting> {
  List<CrawlerTemplate> crawlerTemplates = [];
  bool change = false;

  @override
  void initState() {
    crawlerTemplates = context.read<SettingsController>().crawlerTemps;
    super.initState();
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      crawlerTemplates.insert(newIndex, crawlerTemplates.removeAt(oldIndex));
      List.generate(
          crawlerTemplates.length,
          (index) => crawlerTemplates[index] =
              crawlerTemplates[index].copyWith(priority: index));
    });
    context.read<SettingsController>().changeCrawlerTemplatePriority(
        crawlerTemplates.map((e) => (e.id, e.priority)).toList());
  }

  void modelDisableChange(bool? value, int index) {
    setState(() {
      crawlerTemplates[index] =
          crawlerTemplates[index].copyWith(enabled: value);
    });
    context
        .read<SettingsController>()
        .switchTemplateEnabled(crawlerTemplates[index].id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.bug_report_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'CrawlerTemp',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Long press and drag to switch priority",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () async {},
                      child: const Text(
                        "Import",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )),
                )
              ],
            ))
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(height: crawlerTemplates.length * 60.0, child: _build())
      ],
    );
  }

  Widget _build() {
    ScrollController scrollController = PrimaryScrollController.of(context);
    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        ReorderableSliverList(
          delegate: ReorderableSliverChildBuilderDelegate(
              (BuildContext context, int index) {
            final model = crawlerTemplates[index];
            return Container(
              key: ValueKey(model),
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(model.baseUrl),
                  ),
                  Checkbox(
                      value: !model.enabled,
                      onChanged: (value) {
                        modelDisableChange(!value!, index);
                      })
                ],
              ),
            );
          }, childCount: crawlerTemplates.length),
          onReorder: onReorder,
          buildDraggableFeedback:
              (BuildContext context, BoxConstraints constraints, Widget child) {
            return Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              child: ConstrainedBox(
                constraints: constraints,
                child: child,
              ),
            );
          },
        ),
      ],
    );
  }
}
