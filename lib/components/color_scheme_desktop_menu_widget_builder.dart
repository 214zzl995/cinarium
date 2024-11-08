import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'color_scheme_desktop_menu_widget_builder.dart';
export 'package:super_context_menu/src/default_builder/desktop_menu_widget_builder.dart';
export 'package:super_context_menu/src/default_builder/group_intrinsic_width.dart';
export 'package:super_context_menu/src/scaffold/desktop/menu_widget_builder.dart';
export 'package:super_context_menu/src/scaffold/desktop/menu_widget.dart';

extension on SingleActivator {
  String stringRepresentation() {
    return [
      if (control) 'Ctrl',
      if (alt) 'Alt',
      if (meta) defaultTargetPlatform == TargetPlatform.macOS ? 'Cmd' : 'Meta',
      if (shift) 'Shift',
      trigger.keyLabel,
    ].join('+');
  }
}

class DefaultDesktopMenuTheme {
  final BoxDecoration decorationOuter; // Outside of clip
  final BoxDecoration decorationInner; // Inside of clip
  final Color separatorColor;
  final TextStyle Function(DesktopMenuItemInfo) textStyleForItem;
  final TextStyle Function(DesktopMenuItemInfo, TextStyle)
      textStyleForItemActivator;
  final BoxDecoration Function(DesktopMenuItemInfo) decorationForItem;

  DefaultDesktopMenuTheme({
    required this.decorationOuter,
    required this.decorationInner,
    required this.separatorColor,
    required this.textStyleForItem,
    required this.textStyleForItemActivator,
    required this.decorationForItem,
  });

  static DefaultDesktopMenuTheme themeForColorScheme(ColorScheme colorScheme) {
    return DefaultDesktopMenuTheme(
      decorationOuter: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      decorationInner: BoxDecoration(
        border: Border.all(
          color: colorScheme.surfaceContainerLow.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
        color: colorScheme.surfaceContainerLow.withOpacity(0.3),
      ),
      separatorColor: Colors.grey.shade600,
      textStyleForItem: (info) {
        Color color;
        if (info.selected && info.menuFocused) {
          color = colorScheme.onPrimary;
        } else if (info.destructive) {
          color = colorScheme.error;
        } else if (info.disabled) {
          color = colorScheme.onSurface.withOpacity(0.5);
        } else {
          color = colorScheme.onSurface;
        }
        return TextStyle(
          color: color,
          fontSize: 14.0,
          decoration: TextDecoration.none,
        );
      },
      textStyleForItemActivator: (info, textStyle) {
        return textStyle.copyWith(
          fontSize: 12.5,
          color: textStyle.color!.withOpacity(0.5),
        );
      },
      decorationForItem: (info) {
        Color color;
        if (info.selected && info.menuFocused) {
          color = colorScheme.primary;
        } else if (info.selected) {
          color = colorScheme.primary.withOpacity(0.3);
        } else {
          color = Colors.transparent;
        }
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.0),
        );
      },
    );
  }
}

class ColorSchemeDesktopMenuWidgetBuilder extends DesktopMenuWidgetBuilder {
  ColorSchemeDesktopMenuWidgetBuilder({
    this.maxWidth = 450,
    this.minWidth = 200,
  });

  final double maxWidth;
  final double minWidth;

  late BuildContext _context;

  static DefaultDesktopMenuTheme _themeForContext(BuildContext context) {
    return DefaultDesktopMenuTheme.themeForColorScheme(
        Theme.of(context).colorScheme);
  }

  @override
  Widget buildMenuContainer(
    BuildContext context,
    DesktopMenuInfo menuInfo,
    Widget child,
  ) {
    _context = context;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final theme = _themeForContext(context);
    return Container(
      decoration: theme.decorationOuter.copyWith(
          borderRadius: BorderRadius.circular(6.0 + 1.0 / pixelRatio)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.all(1.0 / pixelRatio),
          child: Container(
            decoration: theme.decorationInner,
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                decoration: TextDecoration.none,
              ),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
                child: GroupIntrinsicWidthContainer(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSeparator(
    BuildContext context,
    DesktopMenuInfo menuInfo,
    MenuSeparator separator,
  ) {
    _context = context;
    final theme = _themeForContext(context);
    final paddingLeft = 10.0 + (menuInfo.hasAnyCheckedItems ? (16 + 6) : 0);
    const paddingRight = 10.0;
    return Container(
      height: 1,
      margin: EdgeInsets.only(
        left: paddingLeft,
        right: paddingRight,
        top: 5,
        bottom: 6,
      ),
      color: theme.separatorColor,
    );
  }

  IconData? _stateToIcon(MenuActionState state) {
    switch (state) {
      case MenuActionState.none:
        return null;
      case MenuActionState.checkOn:
        return Icons.check;
      case MenuActionState.checkOff:
        return null;
      case MenuActionState.checkMixed:
        return Icons.remove;
      case MenuActionState.radioOn:
        return Icons.radio_button_on;
      case MenuActionState.radioOff:
        return Icons.radio_button_off;
    }
  }

  @override
  Widget buildMenuItem(
    BuildContext context,
    DesktopMenuInfo menuInfo,
    Key innerKey,
    DesktopMenuButtonState state,
    MenuElement element,
  ) {
    final theme = _themeForContext(context);
    final itemInfo = DesktopMenuItemInfo(
      destructive: element is MenuAction && element.attributes.destructive,
      disabled: element is MenuAction && element.attributes.disabled,
      menuFocused: menuInfo.focused,
      selected: state.selected,
    );
    final textStyle = theme.textStyleForItem(itemInfo);
    final iconTheme = menuInfo.iconTheme.copyWith(
      size: 16,
      color: textStyle.color,
    );
    final stateIcon =
        element is MenuAction ? _stateToIcon(element.state) : null;
    final Widget? prefix;
    if (stateIcon != null) {
      prefix = Icon(
        stateIcon,
        size: 16,
        color: iconTheme.color,
      );
    } else if (menuInfo.hasAnyCheckedItems) {
      prefix = const SizedBox(width: 16);
    } else {
      prefix = null;
    }
    final image = element.image?.asWidget(iconTheme);

    final Widget? suffix;
    if (element is Menu) {
      suffix = Icon(
        Icons.chevron_right_outlined,
        size: 18,
        color: iconTheme.color,
      );
    } else if (element is MenuAction) {
      final activator = element.activator?.stringRepresentation();
      if (activator != null) {
        suffix = Padding(
          padding: const EdgeInsetsDirectional.only(end: 6),
          child: Text(
            activator,
            style: theme.textStyleForItemActivator(itemInfo, textStyle),
          ),
        );
      } else {
        suffix = null;
      }
    } else {
      suffix = null;
    }

    final child = element is DeferredMenuElement
        ? const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.grey,
              ),
            ),
          )
        : Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            element.title ?? '',
            style: textStyle,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: MouseRegion(
        cursor: element is MenuAction && element.attributes.disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: Container(
          key: innerKey,
          padding: const EdgeInsets.all(8),
          decoration: theme.decorationForItem(itemInfo),
          child: Row(
            children: [
              if (prefix != null) prefix,
              if (prefix != null) const SizedBox(width: 6.0),
              if (image != null) image,
              if (image != null) const SizedBox(width: 4.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: child,
                ),
              ),
              GroupIntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (suffix != null) const SizedBox(width: 6.0),
                    if (suffix != null) suffix,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 不想改源代码 只能用这种抽象的办法关闭了
  void hideMenu() {
    final MenuWidget menuWidget = _context.widget as MenuWidget;
    menuWidget.delegate.hide(itemSelected: false);
  }
}

extension on DesktopMenuInfo {
  bool get hasAnyCheckedItems => (resolvedChildren.any((element) =>
      element is MenuAction && element.state != MenuActionState.none));
}
