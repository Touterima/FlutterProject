// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_recovery_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PasswordRecoveryAdapter extends TypeAdapter<PasswordRecovery> {
  @override
  final int typeId = 3;

  @override
  PasswordRecovery read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordRecovery(
      email: fields[0] as String,
      code: fields[1] as String,
      expiration: fields[2] as String,
      used: fields[3] as bool,
      createdAt: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PasswordRecovery obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.expiration)
      ..writeByte(3)
      ..write(obj.used)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordRecoveryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
