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
              GoRouter.of(context)
                  .go(SettingsRoutes.crawlerTemplate.jumpRouter);
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            style: Theme.of(context).textTheme.bodyMedium,
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


}
