import 'package:cinarium/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingsRoot extends StatelessWidget {
  const SettingsRoot({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var inSecondaryRoute =
        GoRouter.of(context).location.startsWith('/settings/');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          title: Container(
              margin: const EdgeInsets.only(bottom: 20, left: 5, top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: inSecondaryRoute
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.cell,
                    child: GestureDetector(
                      onTap: () {
                        GoRouter.of(context).go('/settings');
                      },
                      child: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: inSecondaryRoute
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                  ),
                  if (inSecondaryRoute)
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Symbols.arrow_back_ios_new,
                          size: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          getCurrentRoute(context).title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    )
                ],
              ))),
      body: child,
    );
  }

  SettingsRoutes getCurrentRoute(BuildContext context) {
    return SettingsRoutes.values.firstWhere((element) =>
        element.router ==
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .pathSegments
            .last);
  }
}
