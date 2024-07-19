// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

import 'package:flutter_acrylic/window_effect.dart';
import 'package:hive/hive.dart';

class WindowEffectAdapter extends TypeAdapter<WindowEffect> {
  @override
  final int typeId = 3;

  @override
  WindowEffect read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WindowEffect.disabled;
      case 1:
        return WindowEffect.solid;
      case 2:
        return WindowEffect.transparent;
      case 3:
        return WindowEffect.aero;
      case 4:
        return WindowEffect.acrylic;
      case 5:
        return WindowEffect.mica;
      case 6:
        return WindowEffect.tabbed;
      case 7:
        return WindowEffect.titlebar;
      case 8:
        return WindowEffect.selection;
      case 9:
        return WindowEffect.menu;
      case 10:
        return WindowEffect.popover;
      case 11:
        return WindowEffect.sidebar;
      case 12:
        return WindowEffect.headerView;
      case 13:
        return WindowEffect.sheet;
      case 14:
        return WindowEffect.windowBackground;
      case 15:
        return WindowEffect.hudWindow;
      case 16:
        return WindowEffect.fullScreenUI;
      case 17:
        return WindowEffect.toolTip;
      case 18:
        return WindowEffect.contentBackground;
      case 19:
        return WindowEffect.underWindowBackground;
      case 20:
        return WindowEffect.underPageBackground;
      default:
        return WindowEffect.disabled;
    }
  }

  @override
  void write(BinaryWriter writer, WindowEffect obj) {
    switch (obj) {
      case WindowEffect.disabled:
        writer.writeByte(0);
        break;
      case WindowEffect.solid:
        writer.writeByte(1);
        break;
      case WindowEffect.transparent:
        writer.writeByte(2);
        break;
      case WindowEffect.aero:
        writer.writeByte(3);
        break;
      case WindowEffect.acrylic:
        writer.writeByte(4);
        break;
      case WindowEffect.mica:
        writer.writeByte(5);
        break;
      case WindowEffect.tabbed:
        writer.writeByte(6);
        break;
      case WindowEffect.titlebar:
        writer.writeByte(7);
        break;
      case WindowEffect.selection:
        writer.writeByte(8);
        break;
      case WindowEffect.menu:
        writer.writeByte(9);
        break;
      case WindowEffect.popover:
        writer.writeByte(10);
        break;
      case WindowEffect.sidebar:
        writer.writeByte(11);
        break;
      case WindowEffect.headerView:
        writer.writeByte(12);
        break;
      case WindowEffect.sheet:
        writer.writeByte(13);
        break;
      case WindowEffect.windowBackground:
        writer.writeByte(14);
        break;
      case WindowEffect.hudWindow:
        writer.writeByte(15);
        break;
      case WindowEffect.fullScreenUI:
        writer.writeByte(16);
        break;
      case WindowEffect.toolTip:
        writer.writeByte(17);
        break;
      case WindowEffect.contentBackground:
        writer.writeByte(18);
        break;
      case WindowEffect.underWindowBackground:
        writer.writeByte(19);
        break;
      case WindowEffect.underPageBackground:
        writer.writeByte(20);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowEffectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
