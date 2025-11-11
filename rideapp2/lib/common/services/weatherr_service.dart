// weather_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ridesharing/common/model/weather_model.dart';

class WeatherService {
  static const String _apiKey = 'c341e920d67c4e54b6d21515250911 ';
  static const String _baseUrl = 'http://api.weatherapi.com/v1';
  
  // Cache
  static WeatherData? _cachedWeather;
  static DateTime? _lastFetch;
  static String? _lastCity;
  
  Future<WeatherData?> getWeatherByCity(String city) async {
    try {
      // Vérifier le cache (10 minutes pour la même ville)
      if (_cachedWeather != null && 
          _lastFetch != null && 
          _lastCity == city &&
          DateTime.now().difference(_lastFetch!).inMinutes < 10) {
        return _cachedWeather;
      }
      
      // Changement ici : ajout de &lang=en pour obtenir les données en anglais
      final response = await http.get(
        Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$city&aqi=no&lang=en')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = WeatherData.fromWeatherApiJson(data);
        
        // Mettre en cache
        _cachedWeather = weather;
        _lastFetch = DateTime.now();
        _lastCity = city;
        
        return weather;
      } else {
        throw Exception('Weather API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Weather service error: $e');
      return null;
    }
  }
  
  // Méthode pour obtenir l'emoji météo basé sur la condition (en anglais)
  String getWeatherEmoji(String condition) {
    final conditionLower = condition.toLowerCase();
    
    if (conditionLower.contains('sunny') || conditionLower.contains('clear')) {
      return '☀️';
    } else if (conditionLower.contains('partly cloudy')) {
      return '🌤️';
    } else if (conditionLower.contains('cloudy') || conditionLower.contains('overcast')) {
      return '☁️';
    } else if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
      return '🌧️';
    } else if (conditionLower.contains('storm') || conditionLower.contains('thunder')) {
      return '⛈️';
    } else if (conditionLower.contains('snow') || conditionLower.contains('blizzard')) {
      return '❄️';
    } else if (conditionLower.contains('fog') || conditionLower.contains('mist')) {
      return '🌫️';
    } else if (conditionLower.contains('wind')) {
      return '💨';
    } else if (conditionLower.contains('ice') || conditionLower.contains('freezing')) {
      return '🧊';
    } else {
      return '🌈';
    }
  }
  
  // Vider le cache
  void clearCache() {
    _cachedWeather = null;
    _lastFetch = null;
    _lastCity = null;
  }
}