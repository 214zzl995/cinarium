import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class EffectMenuColors extends ThemeExtension<EffectMenuColors> {
  const EffectMenuColors({
    required this.danger,
  });

  final Color? danger;

  @override
  EffectMenuColors copyWith({Color? danger}) {
    return EffectMenuColors(
      danger: danger ?? this.danger,
    );
  }

  @override
  EffectMenuColors lerp(ThemeExtension<EffectMenuColors>? other, double t) {
    if (other is! EffectMenuColors) {
      return this;
    }
    return EffectMenuColors(
      danger: Color.lerp(danger, other.danger, t),
    );
  }

  EffectMenuColors harmonized(ColorScheme dynamic) {
    return copyWith(danger: danger!.harmonizeWith(dynamic.primary));
  }
}

@immutable
class MenuItemExtension extends ThemeExtension<MenuItemExtension> {
  const MenuItemExtension(this.width, this.height, this.marginBottom);

  final double width;
  final double height;
  final double marginBottom;

  @override
  ThemeExtension<MenuItemExtension> copyWith() {
    return MenuItemExtension(width, height, marginBottom);
  }

  @override
  ThemeExtension<MenuItemExtension> lerp(
      covariant ThemeExtension<MenuItemExtension>? other, double t) {
    return MenuItemExtension(
      width,
      height,
      marginBottom,
    );
  }
}
