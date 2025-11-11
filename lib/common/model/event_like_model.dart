import 'package:hive/hive.dart';

part 'event_like_model.g.dart';

@HiveType(typeId: 2)
class EventLike extends HiveObject {
  @HiveField(0)
  final int eventId;

  @HiveField(1)
  final int userId;

  @HiveField(2)
  final String createdAt;

  EventLike({
    required this.eventId,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  factory EventLike.fromMap(Map<String, dynamic> map) {
    return EventLike(
      eventId: map['eventId'],
      userId: map['userId'],
      createdAt: map['createdAt'],
    );
  }

  @override
  String toString() {
    return 'EventLike{eventId: $eventId, userId: $userId, createdAt: $createdAt}';
  }
}