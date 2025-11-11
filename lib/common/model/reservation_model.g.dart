// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReservationAdapter extends TypeAdapter<Reservation> {
  @override
  final int typeId = 5;

  @override
  Reservation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reservation(
      id: fields[0] as int?,
      userId: fields[1] as int,
      trajetId: fields[2] as int,
      nbPlacesReservees: fields[3] as int,
      dateReservation: fields[4] as String,
      statut: fields[5] as String?,
      prixTotal: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Reservation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.trajetId)
      ..writeByte(3)
      ..write(obj.nbPlacesReservees)
      ..writeByte(4)
      ..write(obj.dateReservation)
      ..writeByte(5)
      ..write(obj.statut)
      ..writeByte(6)
      ..write(obj.prixTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
