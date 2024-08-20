import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import '../util/hive_util.dart';

part 'theme.g.dart';

@HiveType(typeId: 0)
class CinariumTheme extends ChangeNotifier {
  ColorScheme? _lightColorScheme;
  ColorScheme? _darkColorScheme;

  ColorScheme? get lightColorScheme => _lightColorScheme;

  ColorScheme? get darkColorScheme => _darkColorScheme;

  set lightColorScheme(lightColorScheme) {
    _lightColorScheme = lightColorScheme;
    notifyListeners();
  }

  set darkColorScheme(darkColorScheme) {
    _darkColorScheme = darkColorScheme;
    notifyListeners();
  }

  ///获取ColorScheme
  Future<void> initPlatformState({Color? color}) async {
    try {
      Color? accentColor;
      if (color != null) {
        accentColor = color;
      } else {
        accentColor = await DynamicColorPlugin.getAccentColor();
      }
      if (accentColor != null) {
        _lightColorScheme = ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
        ).harmonized();

        _darkColorScheme = ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ).harmonized();
      }

      _lightColorScheme = _lightColorScheme?.copyWith(
          surface: const Color.fromARGB(255, 250, 250, 250)
      );

      _darkColorScheme = _darkColorScheme?.copyWith(
         surface: const Color.fromARGB(255, 33, 33, 33)
      );

    } on PlatformException {
      debugPrint('dynamic_color: Failed to obtain accent color.');
    }
  }

  ///代表当前的重点色
  @HiveField(0)
  Color? _color;

  Color? get color => _color;

  set color(Color? color) {
    _color = color;

    _lightColorScheme = ColorScheme.fromSeed(
      seedColor: color!,
      brightness: Brightness.light,
    ).harmonized();

    _darkColorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.dark,
    ).harmonized();

    _lightColorScheme = _lightColorScheme?.copyWith(
        surface: const Color.fromARGB(255, 250, 250, 250)
    );

    _darkColorScheme = _darkColorScheme?.copyWith(
        surface: const Color.fromARGB(255, 33, 33, 33)
    );

    notifyListeners();
  }

  /// 添加 autoColor 标志 代表是否使用自动颜色 当这个值变动 也会出发重组 重新计算重点色
  @HiveField(4)
  bool _autoColor = true;

  bool get autoColor => _autoColor;

  set autoColor(bool autoColor) {
    _autoColor = autoColor;
    if (_autoColor) {
      initPlatformState();
    } else {
      initPlatformState(color: _color);
    }
    notifyListeners();
  }

  @HiveField(1)
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  set mode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  @HiveField(2)
  WindowEffect _windowEffect = WindowEffect.disabled;

  WindowEffect get windowEffect => _windowEffect;

  /// 获取背景色
  Color get effectBackgroundColor {
    if (windowEffect == WindowEffect.disabled) {
      if (mode == ThemeMode.light) {
        return lightColorScheme!.surface;
      } else if (mode == ThemeMode.dark) {
        return darkColorScheme!.surface;
      } else {
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        if (brightness == Brightness.light) {
          return lightColorScheme!.surface;
        } else if (brightness == Brightness.dark) {
          return darkColorScheme!.surface;
        } else {
          return Colors.transparent;
        }
      }
    } else {
      return Colors.transparent;
    }
  }

  set windowEffect(WindowEffect windowEffect) {
    _windowEffect = windowEffect;
    notifyListeners();
  }

  set brightness(ThemeMode mode) {
    _mode = mode;

    notifyListeners();
  }

  void setEffect(WindowEffect effect, BuildContext context,
      {Brightness? brightness}) async {
    brightness ??= Theme.of(context).brightness;

    Window.setEffect(
      effect: effect,
      color: [
        WindowEffect.solid,
        WindowEffect.acrylic,
        WindowEffect.disabled,
      ].contains(effect)
          ? Theme.of(context).colorScheme.surface
          : Colors.transparent,
      dark: brightness == Brightness.dark,
    );
  }

  @HiveField(3)
  TextDirection _textDirection = TextDirection.ltr;

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection direction) {
    _textDirection = direction;
    notifyListeners();
  }

  Locale? _locale;

  Locale? get locale => _locale;

  set locale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    save();
    super.notifyListeners();
  }

  void save() async {
    final hiveUtil = await HiveUtil.getInstance();
    await hiveUtil.themeBox.put('theme', this);
  }

  Future<void> init(BuildContext context) async {
    setEffect(windowEffect, context);

  }
}
