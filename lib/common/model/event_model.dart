import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final List<String> oddObjectives;

  @HiveField(5)
  final String date;

  @HiveField(6)
  final String? image;

  @HiveField(7)
  final String? category;

  @HiveField(8)
  final int? price;

  @HiveField(9)
  final String? creationAt;

  @HiveField(10)
  final String? updatedAt;

  @HiveField(11)
  final int userId;

  @HiveField(12)
  final int likeCount;

  // Not stored in Hive - runtime only
  final bool isLiked;
  final dynamic weather;
  final bool isWeatherLoading;
  final String? weatherError;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.oddObjectives,
    required this.date,
    this.image,
    this.category,
    this.price,
    this.creationAt,
    this.updatedAt,
    required this.userId,
    this.likeCount = 0,
    this.isLiked = false,
    this.weather,
    this.isWeatherLoading = false,
    this.weatherError,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'oddObjectives': oddObjectives.join('|'),
      'date': date,
      'image': image,
      'category': category,
      'price': price,
      'creationAt': creationAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'likeCount': likeCount,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    String oddObjectiveData = map['oddObjectives'] ?? '';
    List<String> oddObjectivesList = oddObjectiveData.isNotEmpty 
        ? oddObjectiveData.split('|') 
        : <String>[];
    
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      oddObjectives: oddObjectivesList,
      date: map['date'],
      image: map['image'],
      category: map['category'],
      price: map['price'],
      creationAt: map['creationAt'],
      updatedAt: map['updatedAt'],
      userId: map['userId'],
      likeCount: map['likeCount'] ?? 0,
      isLiked: false,
      weather: null,
      isWeatherLoading: false,
      weatherError: null,
    );
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    String? location,
    List<String>? oddObjectives,
    String? date,
    String? image,
    String? category,
    int? price,
    String? creationAt,
    String? updatedAt,
    int? userId,
    int? likeCount,
    bool? isLiked,
    dynamic weather,
    bool? isWeatherLoading,
    String? weatherError,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      oddObjectives: oddObjectives ?? this.oddObjectives,
      date: date ?? this.date,
      image: image ?? this.image,
      category: category ?? this.category,
      price: price ?? this.price,
      creationAt: creationAt ?? this.creationAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      weather: weather ?? this.weather,
      isWeatherLoading: isWeatherLoading ?? this.isWeatherLoading,
      weatherError: weatherError ?? this.weatherError,
    );
  }

  bool isOwner(int currentUserId) {
    return userId == currentUserId;
  }

  bool hasSdg(String sdg) {
    return oddObjectives.contains(sdg);
  }
}