import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.danger,
  });

  final Color? danger;

  @override
  CustomColors copyWith({Color? danger}) {
    return CustomColors(
      danger: danger ?? this.danger,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      danger: Color.lerp(danger, other.danger, t),
    );
  }

  CustomColors harmonized(ColorScheme dynamic) {
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
