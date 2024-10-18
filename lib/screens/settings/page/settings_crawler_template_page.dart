import 'package:bridge/call_rust/task/crawler.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

import '../../../components/scroll_animator.dart';
import '../controllers/settings_controller.dart';

class SettingsCrawlerTemplatePage extends StatelessWidget {
  const SettingsCrawlerTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 10,
                ),
                child: Lottie.asset(
                  'assets/lottie/monitor_folder.json',
                  width: 150,
                  height: 150,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 20),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Icon(
                            Symbols.create_new_folder,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            weight: 400,
                          ),
                          const SizedBox(width: 10),
                          const Text('Add Folder'),
                        ],
                      )),
                ),
              )
            ],
          ),
        ),
        Expanded(child: _buildITemplatesList(context))
      ],
    );
  }

  Widget _buildITemplatesList(BuildContext context) {
    return ScrollAnimator(
        scrollSpeed: 0.5,
        builder: (context, controller, physics) => CustomScrollView(
              controller: controller,
              physics: physics,
              slivers: <Widget>[
                Selector<SettingsController, List<CrawlerTemplate>>(
                  selector: (_, settings) => settings.crawlerTemplates,
                  builder: (BuildContext context,
                      List<CrawlerTemplate> crawlerTemplates, Widget? child) {
                    return ReorderableSliverList(
                      delegate: ReorderableSliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        final template = context
                            .read<SettingsController>()
                            .crawlerTemplates[index];
                        return Container(
                          key: ValueKey(template),
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 14),
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
                    );
                  },
                )
              ],
            ));
  }
}
