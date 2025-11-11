// lib/feature/dashboard/trips/service/map_service.dart




import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:ridesharing/common/database/sqlflite_database_helper.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:ridesharing/feature/dashboard/trips/service/map_service.dart';
import 'package:flutter/foundation.dart';

class MapService {
  // API Nominatim pour géocodage (gratuit, OpenStreetMap)
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  
  // API OSRM pour calcul d'itinéraire (gratuit, open source)
  static const String _osrmBaseUrl = 'https://router.project-osrm.org';

  /// Obtenir les coordonnées d'une ville
  Future<Map<String, double>?> getCityCoordinates(String cityName) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?q=$cityName,Tunisia&format=json&limit=1'
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RideApp/1.0', // Obligatoire pour Nominatim
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final location = data[0];
          return {
            'latitude': double.parse(location['lat']),
            'longitude': double.parse(location['lon']),
          };
        }
      }

      if (kDebugMode) {
        print('❌ Coordonnées non trouvées pour: $cityName');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur géocodage: $e');
      }
      return null;
    }
  }

  /// Calculer l'itinéraire entre deux villes
  Future<Map<String, dynamic>?> calculateRoute(
    String fromCity,
    String toCity,
  ) async {
    try {
      // 1. Obtenir les coordonnées des deux villes
      final fromCoords = await getCityCoordinates(fromCity);
      final toCoords = await getCityCoordinates(toCity);

      if (fromCoords == null || toCoords == null) {
        if (kDebugMode) {
          print('❌ Impossible de trouver les coordonnées');
        }
        return null;
      }

      // 2. Calculer l'itinéraire avec OSRM
      final url = Uri.parse(
        '$_osrmBaseUrl/route/v1/driving/'
        '${fromCoords['longitude']},${fromCoords['latitude']};'
        '${toCoords['longitude']},${toCoords['latitude']}'
        '?overview=full&geometries=geojson&steps=true'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final distanceKm = route['distance'] / 1000; // mètres -> km
          final durationMin = route['duration'] / 60; // secondes -> minutes

          if (kDebugMode) {
            print('✅ Itinéraire calculé:');
            print('   Distance: ${distanceKm.toStringAsFixed(1)} km');
            print('   Durée: ${durationMin.toStringAsFixed(0)} min');
          }

          return {
            'distance_km': distanceKm,
            'duration_minutes': durationMin,
            'distance_text': '${distanceKm.toStringAsFixed(1)} km',
            'duration_text': _formatDuration(durationMin),
            'from_coords': fromCoords,
            'to_coords': toCoords,
            'geometry': route['geometry']['coordinates'], // Pour tracer la route
            'steps': route['legs'][0]['steps'], // Étapes détaillées
          };
        }
      }

      if (kDebugMode) {
        print('❌ Erreur calcul itinéraire: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur calcul itinéraire: $e');
      }
      return null;
    }
  }

  /// Formater la durée en texte lisible
  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)} min';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes < 1) {
      return '${hours}h';
    }
    
    return '${hours}h ${remainingMinutes.toStringAsFixed(0)}min';
  }

  /// Calculer le prix suggéré basé sur la distance
  double calculateSuggestedPrice(double distanceKm) {
    // Prix de base : 0.15 TND/km
    // Minimum : 5 TND
    final basePrice = distanceKm * 0.15;
    return basePrice < 5.0 ? 5.0 : basePrice;
  }

  /// Obtenir les détails d'une ville
  Future<Map<String, dynamic>?> getCityDetails(String cityName) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?q=$cityName,Tunisia&format=json&limit=1&addressdetails=1'
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RideApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final location = data[0];
          return {
            'display_name': location['display_name'],
            'latitude': double.parse(location['lat']),
            'longitude': double.parse(location['lon']),
            'address': location['address'],
          };
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur détails ville: $e');
      }
      return null;
    }
  }
}



class EnhancedTripService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final MapService _mapService = MapService();
  static const String _currentUserId = 'current_user_id';

  /// Ajouter un trajet avec calcul automatique de distance
  Future<Map<String, dynamic>> addTripWithRoute(TripModel trip) async {
    try {
      // 1. Calculer l'itinéraire
      final routeData = await _mapService.calculateRoute(trip.from, trip.to);
      
      if (routeData == null) {
        // Ajouter quand même le trajet sans données d'itinéraire
        await _dbHelper.insertTrip(trip);
        return {
          'success': true,
          'trip': trip,
          'route': null,
          'message': 'Trajet ajouté (calcul d\'itinéraire indisponible)',
        };
      }

      // 2. Ajouter le trajet
      await _dbHelper.insertTrip(trip);

      if (kDebugMode) {
        print('✅ Trajet ajouté avec itinéraire calculé');
        print('   Distance: ${routeData['distance_text']}');
        print('   Durée: ${routeData['duration_text']}');
      }

      return {
        'success': true,
        'trip': trip,
        'route': routeData,
        'message': 'Trajet ajouté avec succès',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur ajout trajet: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Obtenir un trajet avec ses informations d'itinéraire
  Future<Map<String, dynamic>?> getTripWithRoute(String tripId) async {
    try {
      final trips = await _dbHelper.getAllTrips();
      final trip = trips.firstWhere((t) => t.id == tripId);

      // Calculer l'itinéraire
      final routeData = await _mapService.calculateRoute(trip.from, trip.to);

      return {
        'trip': trip,
        'route': routeData,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur récupération trajet: $e');
      }
      return null;
    }
  }

  /// Calculer le prix suggéré pour un trajet
  Future<double?> calculateSuggestedPrice(String fromCity, String toCity) async {
    try {
      final routeData = await _mapService.calculateRoute(fromCity, toCity);
      
      if (routeData != null) {
        final distanceKm = routeData['distance_km'] as double;
        return _mapService.calculateSuggestedPrice(distanceKm);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur calcul prix: $e');
      }
      return null;
    }
  }

  /// Vérifier si deux villes sont valides
  Future<bool> validateCities(String fromCity, String toCity) async {
    try {
      final fromCoords = await _mapService.getCityCoordinates(fromCity);
      final toCoords = await _mapService.getCityCoordinates(toCity);
      
      return fromCoords != null && toCoords != null;
    } catch (e) {
      return false;
    }
  }
}
