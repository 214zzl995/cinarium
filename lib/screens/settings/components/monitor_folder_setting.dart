import 'package:cinarium/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/settings/controllers/settings_controller.dart';

class MonitorFolderSetting extends StatelessWidget {
  const MonitorFolderSetting({super.key});

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
          GoRouter.of(context).go(SettingsRoutes.monitorFolder.jumpRouter);
        },
        child: ValueListenableBuilder(
          valueListenable: hover,
          builder: (context, value, child) {
            return Container(
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
                child: child);
          },
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.manage_search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    weight: 300,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monitor folder',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Listen for video file changes in this list folder',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )),
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
                    ],
                  ))
                ],
              ),
              // _buildSearchFolderList(context)
            ],
          ),
        ),
      ),
    );
  }


}
