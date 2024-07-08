// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SmovbookThemeAdapter extends TypeAdapter<SmovbookTheme> {
  @override
  final int typeId = 0;

  @override
  SmovbookTheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmovbookTheme()
      .._color = fields[0] as Color?
      .._autoColor = fields[4] as bool
      .._mode = fields[1] as ThemeMode
      .._windowEffect = fields[2] as WindowEffect
      .._textDirection = fields[3] as TextDirection;
  }

  @override
  void write(BinaryWriter writer, SmovbookTheme obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj._color)
      ..writeByte(4)
      ..write(obj._autoColor)
      ..writeByte(1)
      ..write(obj._mode)
      ..writeByte(2)
      ..write(obj._windowEffect)
      ..writeByte(3)
      ..write(obj._textDirection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmovbookThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
