import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class CinariumAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CinariumAppBar(
      {super.key,
      this.title,
      this.actions,
      this.leading,
      this.flexibleSpace,
      this.bottom,
      this.elevation,
      this.shape,
      this.backgroundColor,
      this.iconTheme,
      this.actionsIconTheme,
      this.primary = true,
      this.centerTitle,
      this.titleSpacing,
      this.toolbarOpacity = 1.0,
      this.bottomOpacity = 1.0,
      this.toolbarHeight,
      this.leadingWidth,
      this.toolbarTextStyle,
      this.titleTextStyle,
      this.systemOverlayStyle,
      this.excludeHeaderSemantics = false,
      this.foregroundColor,
      this.shadowColor,
      this.automaticallyImplyLeading = true,
      this.notificationPredicate = defaultScrollNotificationPredicate,
      this.scrolledUnderElevation,
      this.surfaceTintColor,
      this.windowButtonHeight});

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final double? elevation;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool? centerTitle;
  final double? titleSpacing;
  final double? toolbarHeight;
  final double? leadingWidth;
  final TextStyle? toolbarTextStyle;
  final TextStyle? titleTextStyle;
  final Color? foregroundColor;
  final Color? shadowColor;
  final bool primary;
  final double toolbarOpacity;
  final double bottomOpacity;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool excludeHeaderSemantics;
  final bool automaticallyImplyLeading;
  final ScrollNotificationPredicate notificationPredicate;
  final double? scrolledUnderElevation;
  final Color? surfaceTintColor;
  final double? windowButtonHeight;

  @override
  State<CinariumAppBar> createState() => _CinariumAppBarState();

  @override
  Size get preferredSize =>
      _PreferredAppBarSize(toolbarHeight, bottom?.preferredSize.height);
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
      : super.fromHeight(
            (toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}

class _CinariumAppBarState extends State<CinariumAppBar> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }

  void _showCloseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm close'),
          content: const Text('Are you sure you want to close this window?'),
          actions: [
            FilledButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                windowManager.destroy();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      _showCloseDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final movableArea = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        onDoubleTap: () async {
          bool isMaximized = await windowManager.isMaximized();
          if (!isMaximized) {
            windowManager.maximize();
          } else {
            windowManager.unmaximize();
          }
        },
        child: AppBar(
            title: widget.title,
            leading: widget.leading,
            flexibleSpace: widget.flexibleSpace,
            bottom: widget.bottom,
            elevation: widget.elevation,
            shape: widget.shape,
            backgroundColor: widget.backgroundColor,
            iconTheme: widget.iconTheme,
            actionsIconTheme: widget.actionsIconTheme,
            primary: widget.primary,
            centerTitle: widget.centerTitle,
            titleSpacing: widget.titleSpacing,
            toolbarOpacity: widget.toolbarOpacity,
            bottomOpacity: widget.bottomOpacity,
            toolbarHeight: widget.toolbarHeight,
            leadingWidth: widget.leadingWidth,
            toolbarTextStyle: widget.toolbarTextStyle,
            titleTextStyle: widget.titleTextStyle,
            systemOverlayStyle: widget.systemOverlayStyle,
            excludeHeaderSemantics: widget.excludeHeaderSemantics,
            foregroundColor: widget.foregroundColor,
            shadowColor: widget.shadowColor,
            automaticallyImplyLeading: widget.automaticallyImplyLeading,
            notificationPredicate: widget.notificationPredicate,
            scrolledUnderElevation: widget.scrolledUnderElevation,
            surfaceTintColor: widget.surfaceTintColor));

    final windowButton = [
      SizedBox(
        height: widget.windowButtonHeight,
        child: WindowCaptionButton.minimize(
          brightness: Theme.of(context).brightness,
          onPressed: () async {
            bool isMinimized = await windowManager.isMinimized();
            if (isMinimized) {
              windowManager.restore();
            } else {
              windowManager.minimize();
            }
          },
        ),
      ),
      SizedBox(
        height: widget.windowButtonHeight,
        child: FutureBuilder<bool>(
          future: windowManager.isMaximized(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == true) {
              return WindowCaptionButton.unmaximize(
                brightness: Theme.of(context).brightness,
                onPressed: () {
                  windowManager.unmaximize();
                },
              );
            }
            return WindowCaptionButton.maximize(
              brightness: Theme.of(context).brightness,
              onPressed: () {
                windowManager.maximize();
              },
            );
          },
        ),
      ),
      SizedBox(
        height: widget.windowButtonHeight,
        child: WindowCaptionButton.close(
          brightness: Theme.of(context).brightness,
          onPressed: () async {
            await windowManager.close();
          },
          icon: const Icon(Icons.close),
        ),
      ),
    ];

    return Semantics(
        container: true,
        child: Row(
          children: [
            Expanded(
              child: movableArea,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.actions ?? [],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: windowButton,
              ),
            )
          ],
        ));
  }
}
