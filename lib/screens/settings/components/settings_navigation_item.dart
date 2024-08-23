import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinarium/routes/app_pages.dart';

class SettingNavigationItem extends StatefulWidget {
  const SettingNavigationItem({Key? key, required this.settingRoute})
      : super(key: key);

  final SettingRoutes settingRoute;

  @override
  SettingNavigationItemState createState() => SettingNavigationItemState();
}

class SettingNavigationItemState extends State<SettingNavigationItem> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          GoRouter.of(context).go(widget.settingRoute.router);
        },
        child: Text(
          widget.settingRoute.name.capitalize(),
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: GoRouter.of(context).location == widget.settingRoute.router
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
