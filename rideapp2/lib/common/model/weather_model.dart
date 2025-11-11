// weather_model.dart
class WeatherData {
  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final String condition;
  final DateTime lastUpdated;

  WeatherData({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.condition,
    required this.lastUpdated,
  });

  factory WeatherData.fromWeatherApiJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final condition = current['condition'];
    
    return WeatherData(
      city: location['name'] ?? 'Unknown',
      country: location['country'] ?? '',
      temperature: (current['temp_c'] ?? 0).toDouble(),
      feelsLike: (current['feelslike_c'] ?? 0).toDouble(),
      humidity: current['humidity'] ?? 0,
      windSpeed: (current['wind_kph'] ?? 0).toDouble(),
      description: condition['text'] ?? '',
      icon: condition['icon'] ?? '',
      condition: condition['text'] ?? '',
      lastUpdated: DateTime.now(),
    );
  }

  // URL complète pour l'icône (WeatherAPI fournit des URLs complètes)
  String get iconUrl => icon.startsWith('http') ? icon : 'https:${icon}';
  
  String get formattedTemperature => '${temperature.round()}°C';
  String get formattedFeelsLike => 'Feels like ${feelsLike.round()}°C'; // Anglais
  String get formattedHumidity => '$humidity%';
  String get formattedWindSpeed => '${windSpeed.round()} km/h';
  
  String get lastUpdatedFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inMinutes < 1) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return 'On ${lastUpdated.day}/${lastUpdated.month}';
  }
}