// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wheel_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WheelItemAdapter extends TypeAdapter<WheelItem> {
  @override
  final typeId = 1;

  @override
  WheelItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WheelItem(
      label: fields[0] as String,
      colorValue: (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, WheelItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WheelItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
