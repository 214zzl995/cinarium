// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

import 'dart:ui';

import 'package:hive/hive.dart';

class TextDirectionAdapter extends TypeAdapter<TextDirection> {
  @override
  final int typeId = 4;

  @override
  TextDirection read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TextDirection.rtl;
      case 1:
        return TextDirection.ltr;
      default:
        return TextDirection.rtl;
    }
  }

  @override
  void write(BinaryWriter writer, TextDirection obj) {
    switch (obj) {
      case TextDirection.rtl:
        writer.writeByte(0);
        break;
      case TextDirection.ltr:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
