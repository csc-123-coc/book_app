// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RenterAdapter extends TypeAdapter<Renter> {
  @override
  final int typeId = 1;

  @override
  Renter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Renter(
      fullName: fields[0] as String,
      contact: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Renter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.fullName)
      ..writeByte(1)
      ..write(obj.contact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
