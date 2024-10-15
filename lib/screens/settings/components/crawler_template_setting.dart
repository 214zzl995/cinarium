import 'package:bridge/call_rust/task/crawler.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:cinarium/screens/settings/controllers/settings_controller.dart';

import '../../../routes/app_pages.dart';

class CrawlerTemplateSetting extends StatelessWidget {
  const CrawlerTemplateSetting({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> hover = ValueNotifier<bool>(false);

    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          hover.value = true;
        },
        onExit: (event) {
          hover.value = false;
        },
        child: GestureDetector(
            onTap: () {
              GoRouter.of(context).go(SettingsRoutes.crawlerTemplate.jumpRouter);
            },
            child: Container(
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.travel_explore,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          weight: 300,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            'CrawlerTemp',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                        ),
                        const Expanded(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Symbols.arrow_forward_ios,
                              size: 15,
                            ),
                            SizedBox(
                              width: 18,
                            )
                            // const Text(
                            //   "Long press and drag to switch priority",
                            //   style: TextStyle(
                            //     color: Colors.grey,
                            //     fontSize: 12,
                            //   ),
                            //   textAlign: TextAlign.right,
                            // ),
                          ],
                        ))
                      ],
                    ),
                    // _buildITemplatesList(context)
                  ],
                ))));
  }

  Widget _buildITemplatesList(BuildContext context) {
    ScrollController scrollController = PrimaryScrollController.of(context);
    return Selector<SettingsController, List<CrawlerTemplate>>(
      selector: (_, settings) => settings.crawlerTemplates,
      builder: (BuildContext context, List<CrawlerTemplate> crawlerTemplates,
          Widget? child) {
        return SizedBox(
          height: crawlerTemplates.length * 60.0,
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              ReorderableSliverList(
                delegate: ReorderableSliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final template = context
                      .read<SettingsController>()
                      .crawlerTemplates[index];
                  return Container(
                    key: ValueKey(template),
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(template.baseUrl),
                        ),
                        Selector<SettingsController, bool>(
                            builder: (_, enabled, __) {
                              return Checkbox(
                                  value: enabled,
                                  onChanged: (value) {
                                    context
                                        .read<SettingsController>()
                                        .modelDisableChange(value, index);
                                  });
                            },
                            selector: (_, settings) =>
                                settings.crawlerTemplates[index].enabled),
                      ],
                    ),
                  );
                }, childCount: crawlerTemplates.length),
                onReorder:
                    context.read<SettingsController>().onTemplatesReorder,
                buildDraggableFeedback: (BuildContext context,
                    BoxConstraints constraints, Widget child) {
                  return SizedBox(
                    height: 58,
                    child: ConstrainedBox(
                      constraints: constraints,
                      child: child,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
