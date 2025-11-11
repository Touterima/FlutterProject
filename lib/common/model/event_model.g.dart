// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 1;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as int?,
      title: fields[1] as String,
      description: fields[2] as String,
      location: fields[3] as String,
      oddObjectives: (fields[4] as List).cast<String>(),
      date: fields[5] as String,
      image: fields[6] as String?,
      category: fields[7] as String?,
      price: fields[8] as int?,
      creationAt: fields[9] as String?,
      updatedAt: fields[10] as String?,
      userId: fields[11] as int,
      likeCount: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.oddObjectives)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.image)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.price)
      ..writeByte(9)
      ..write(obj.creationAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.userId)
      ..writeByte(12)
      ..write(obj.likeCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
