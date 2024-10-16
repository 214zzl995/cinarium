import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';

import '../util/hive_util.dart';

part 'theme.g.dart';

@HiveType(typeId: 0)
class CinariumTheme extends ChangeNotifier {
  ColorScheme? _lightColorScheme;
  ColorScheme? _darkColorScheme;

  late Brightness _brightness = _themeMode == ThemeMode.dark
      ? Brightness.dark
      : _themeMode == ThemeMode.light
          ? Brightness.light
          : WidgetsBinding.instance.platformDispatcher.platformBrightness;

  @HiveField(0)
  Color? _color;
  @HiveField(1)
  ThemeMode _themeMode = ThemeMode.system;
  @HiveField(2)
  WindowEffect _windowEffect = WindowEffect.mica;
  @HiveField(3)
  TextDirection _textDirection = TextDirection.ltr;
  @HiveField(4)
  bool _autoColor = true;

  Locale? _locale;

  Locale? get locale => _locale;

  TextDirection get textDirection => _textDirection;

  WindowEffect get windowEffect => _windowEffect;

  ThemeMode get themeMode => _themeMode;

  bool get autoColor => _autoColor;

  Color? get color => _color;

  ColorScheme? get lightColorScheme => _lightColorScheme;

  ColorScheme? get darkColorScheme => _darkColorScheme;

  Brightness get brightness => _brightness;

  Future<void> initPlatformState({Color? color}) async {
    try {
      Color? accentColor;

      accentColor = color ?? await DynamicColorPlugin.getAccentColor();
      debugPrint('dynamic_color: $accentColor');
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

      setSurfaceColor();
    } on PlatformException {
      debugPrint('dynamic_color: Failed to obtain accent color.');
    }
  }

  Future<void> refreshWindowEffect() async {
    await windowManager.waitUntilReadyToShow().then((_) async {
      ThemeMode themeMode;
      if (_themeMode != ThemeMode.system) {
        themeMode = _themeMode;
      } else {
        themeMode =
            brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }

      Window.setEffect(
        effect: windowEffect,
        color: effectBackgroundColor,
        dark: themeMode == ThemeMode.dark,
      );
    });
  }

  set brightness(Brightness brightness) {
    _brightness = brightness;
    refreshWindowEffect();
  }

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

    setSurfaceColor();

    notifyListeners();
  }

  void setSurfaceColor() {
    int opacity;

    if (windowEffect == WindowEffect.tabbed ||
        windowEffect == WindowEffect.mica) {
      opacity = 130;
    } else if (windowEffect == WindowEffect.acrylic) {
      opacity = 0;
    } else {
      opacity = 255;
    }

    _lightColorScheme = _lightColorScheme?.copyWith(
        surface: Color.fromARGB(opacity, 250, 250, 250));

    _darkColorScheme = _darkColorScheme?.copyWith(
        surface: Color.fromARGB(opacity, 33, 33, 33));
  }

  set autoColor(bool autoColor) {
    _autoColor = autoColor;
    if (_autoColor) {
      initPlatformState();
    } else {
      initPlatformState(color: _color);
    }
    notifyListeners();
  }

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    if (mode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _brightness = brightness;
    } else if (mode == ThemeMode.light) {
      _brightness = Brightness.light;
    } else {
      _brightness = Brightness.dark;
    }
    refreshWindowEffect();
    notifyListeners();
  }

  /// 获取背景色
  Color get effectBackgroundColor {
    if (windowEffect == WindowEffect.disabled) {
      if (_themeMode == ThemeMode.light) {
        return lightColorScheme!.surface;
      } else if (_themeMode == ThemeMode.dark) {
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

  set windowEffect(WindowEffect effect) {
    _windowEffect = effect;
    final surfaceColor = brightness == Brightness.light
        ? lightColorScheme!.surface
        : darkColorScheme!.surface;
    Window.setEffect(
      effect: effect,
      color: [
        WindowEffect.solid,
        WindowEffect.acrylic,
        WindowEffect.disabled,
      ].contains(effect)
          ? surfaceColor
          : Colors.transparent,
      dark: brightness == Brightness.dark,
    );
  }

  set textDirection(TextDirection direction) {
    _textDirection = direction;
    notifyListeners();
  }

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
}
