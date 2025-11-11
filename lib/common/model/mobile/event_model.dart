// models/event_model.dart
import 'package:ridesharing/common/model/weather_model.dart';

class Event {
  final int? id;
  final String title;
  final String description;
  final String location;
  final List<String> oddObjectives;
  final String date;
  final String? image;
  final String? category;
  final int? price;
  final String? creationAt;
  final String? updatedAt;
  final int userId;
  final int likeCount; // NEW: Like counter
  final bool isLiked; // NEW: Like status for current user
  
  // NEW: Weather data fields
  final WeatherData? weather;
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
    this.likeCount = 0, // NEW
    this.isLiked = false, // NEW
    this.weather, // NEW: Weather data
    this.isWeatherLoading = false, // NEW: Weather loading state
    this.weatherError, // NEW: Weather error message
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
      'likeCount': likeCount, // NEW
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
      likeCount: map['likeCount'] ?? 0, // NEW
      isLiked: false, // This will be set separately
      weather: null, // Will be loaded separately
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
    int? likeCount, // NEW
    bool? isLiked, // NEW
    WeatherData? weather, // NEW: Weather data
    bool? isWeatherLoading, // NEW: Weather loading state
    String? weatherError, // NEW: Weather error message
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
      likeCount: likeCount ?? this.likeCount, // NEW
      isLiked: isLiked ?? this.isLiked, // NEW
      weather: weather ?? this.weather, // NEW
      isWeatherLoading: isWeatherLoading ?? this.isWeatherLoading, // NEW
      weatherError: weatherError ?? this.weatherError, // NEW
    );
  }

  bool isOwner(int currentUserId) {
    return userId == currentUserId;
  }

  bool hasSdg(String sdg) {
    return oddObjectives.contains(sdg);
  }
}