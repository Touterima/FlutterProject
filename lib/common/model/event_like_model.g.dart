// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_like_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventLikeAdapter extends TypeAdapter<EventLike> {
  @override
  final int typeId = 2;

  @override
  EventLike read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventLike(
      eventId: fields[0] as int,
      userId: fields[1] as int,
      createdAt: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EventLike obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventLikeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
