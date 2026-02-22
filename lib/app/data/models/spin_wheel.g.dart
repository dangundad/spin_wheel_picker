// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spin_wheel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpinWheelAdapter extends TypeAdapter<SpinWheel> {
  @override
  final typeId = 0;

  @override
  SpinWheel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpinWheel(
      id: fields[0] as String,
      name: fields[1] as String,
      items: (fields[2] as List).cast<WheelItem>(),
      resultHistory: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SpinWheel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.resultHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpinWheelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
