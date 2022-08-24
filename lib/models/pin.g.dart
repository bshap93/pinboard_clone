// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PinAdapter extends TypeAdapter<Pin> {
  @override
  final int typeId = 0;

  @override
  Pin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pin(
      id: fields[0] as String,
      wasRead: fields[1] as bool,
      url: fields[2] as String,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Pin obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.wasRead)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
