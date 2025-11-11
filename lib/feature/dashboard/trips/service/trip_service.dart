//lib/feature/dashboard/trips/service/trip_service.dart
// lib/feature/dashboard/trips/service/trip_service.dart
//lib/feature/dashboard/trips/service/trip_service.dart
import 'package:ridesharing/common/database/sqlflite_database_helper.dart';
import 'package:ridesharing/common/model/trip_model.dart';
import 'package:flutter/foundation.dart';

class TripService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String _currentUserId = 'current_user_id'; // Simuler un utilisateur connecté

  // Obtenir tous les trajets
  Future<List<TripModel>> getAllTrips() async {
    try {
      return await _dbHelper.getAllTrips();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la récupération des trajets: $e');
      }
      return [];
    }
  }

  // Ajouter un trajet
  Future<bool> addTrip(TripModel trip) async {
    try {
      await _dbHelper.insertTrip(trip);
      if (kDebugMode) {
        print('✅ Trajet ajouté avec succès: ${trip.from} → ${trip.to}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'ajout du trajet: $e');
      }
      return false;
    }
  }

  // Mettre à jour un trajet
  Future<bool> updateTrip(TripModel updatedTrip) async {
    try {
      await _dbHelper.updateTrip(updatedTrip);
      if (kDebugMode) {
        print('✅ Trajet mis à jour: ${updatedTrip.id}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la mise à jour: $e');
      }
      return false;
    }
  }

  // Supprimer un trajet
  Future<bool> deleteTrip(String tripId) async {
    try {
      await _dbHelper.deleteTrip(tripId);
      if (kDebugMode) {
        print('✅ Trajet supprimé: $tripId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la suppression: $e');
      }
      return false;
    }
  }

  // Rechercher des trajets
  Future<List<TripModel>> searchTrips(String from, String to) async {
    try {
      return await _dbHelper.searchTrips(from, to);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la recherche: $e');
      }
      return [];
    }
  }

  // Réserver un trajet
  Future<bool> bookTrip(String tripId, int seatsToBook) async {
    try {
      final success = await _dbHelper.bookTrip(tripId, _currentUserId, seatsToBook);
      if (success && kDebugMode) {
        print('✅ Réservation effectuée: $seatsToBook place(s)');
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la réservation: $e');
      }
      return false;
    }
  }

  // Annuler une réservation
  Future<bool> cancelBooking(String tripId, int seatsToCancel) async {
    try {
      final success = await _dbHelper.cancelBooking(tripId, _currentUserId);
      if (success && kDebugMode) {
        print('✅ Réservation annulée');
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'annulation: $e');
      }
      return false;
    }
  }

  // Obtenir les trajets réservés par l'utilisateur actuel
  Future<List<TripModel>> getMyBookedTrips() async {
    try {
      return await _dbHelper.getBookedTripsByUser(_currentUserId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la récupération des réservations: $e');
      }
      return [];
    }
  }

  // Vérifier si l'utilisateur a réservé un trajet
  Future<bool> hasUserBookedTrip(String tripId) async {
    try {
      return await _dbHelper.hasUserBookedTrip(tripId, _currentUserId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la vérification: $e');
      }
      return false;
    }
  }

  // Initialiser avec des données de test
  Future<void> initializeSampleData() async {
    try {
      // Vérifier si des trajets existent déjà
      final trips = await getAllTrips();
      
      if (trips.isEmpty) {
        if (kDebugMode) {
          print('📝 Initialisation des données de test...');
        }
        
        // Ajouter des trajets d'exemple
        final sampleTrips = [
          TripModel(
            id: 'trip_${DateTime.now().millisecondsSinceEpoch}_1',
            from: 'Tunis',
            to: 'Sousse',
            driverName: 'Ahmed Ben Ali',
            driverPhone: '+216 20 123 456',
            departureTime: DateTime.now().add(const Duration(hours: 2)),
            totalSeats: 4,
            availableSeats: 4,
            pricePerSeat: 15.0,
            vehicleType: 'Car',
          ),
          TripModel(
            id: 'trip_${DateTime.now().millisecondsSinceEpoch}_2',
            from: 'Sfax',
            to: 'Tunis',
            driverName: 'Fatma Trabelsi',
            driverPhone: '+216 22 987 654',
            departureTime: DateTime.now().add(const Duration(hours: 4)),
            totalSeats: 3,
            availableSeats: 3,
            pricePerSeat: 20.0,
            vehicleType: 'Car',
          ),
          TripModel(
            id: 'trip_${DateTime.now().millisecondsSinceEpoch}_3',
            from: 'Tunis',
            to: 'Bizerte',
            driverName: 'Mohamed Gharbi',
            driverPhone: '+216 25 456 789',
            departureTime: DateTime.now().add(const Duration(hours: 6)),
            totalSeats: 2,
            availableSeats: 2,
            pricePerSeat: 10.0,
            vehicleType: 'Bike',
          ),
          TripModel(
            id: 'trip_${DateTime.now().millisecondsSinceEpoch}_4',
            from: 'Monastir',
            to: 'Tunis',
            driverName: 'Salma Bouazizi',
            driverPhone: '+216 21 345 678',
            departureTime: DateTime.now().add(const Duration(days: 1)),
            totalSeats: 4,
            availableSeats: 4,
            pricePerSeat: 18.0,
            vehicleType: 'Taxi',
          ),
          TripModel(
            id: 'trip_${DateTime.now().millisecondsSinceEpoch}_5',
            from: 'Tunis',
            to: 'Nabeul',
            driverName: 'Karim Jebali',
            driverPhone: '+216 23 567 890',
            departureTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
            totalSeats: 3,
            availableSeats: 3,
            pricePerSeat: 12.0,
            vehicleType: 'Car',
          ),
        ];

        for (var trip in sampleTrips) {
          await addTrip(trip);
        }

        if (kDebugMode) {
          print('✅ ${sampleTrips.length} trajets d\'exemple ajoutés');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ ${trips.length} trajet(s) déjà existant(s)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'initialisation: $e');
      }
    }
  }

  // Obtenir l'ID de l'utilisateur actuel (pour une utilisation future)
  String getCurrentUserId() {
    return _currentUserId;
  }
}


/*
import 'package:ridesharing/common/database/database_helper.dart';
import 'package:ridesharing/common/model/trip_model.dart';

class TripService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String _currentUserId = 'current_user_id'; // Simuler un utilisateur connecté

  // Obtenir tous les trajets
  Future<List<TripModel>> getAllTrips() async {
    return await _dbHelper.getAllTrips();
  }

  // Ajouter un trajet
  Future<void> addTrip(TripModel trip) async {
    await _dbHelper.insertTrip(trip);
  }

  // Mettre à jour un trajet
  Future<void> updateTrip(TripModel updatedTrip) async {
    await _dbHelper.updateTrip(updatedTrip);
  }

  // Supprimer un trajet
  Future<void> deleteTrip(String tripId) async {
    await _dbHelper.deleteTrip(tripId);
  }

  // Rechercher des trajets
  Future<List<TripModel>> searchTrips(String from, String to) async {
    return await _dbHelper.searchTrips(from, to);
  }

  // Réserver un trajet
  Future<bool> bookTrip(String tripId, int seatsToBook) async {
    return await _dbHelper.bookTrip(tripId, _currentUserId, seatsToBook);
  }

  // Annuler une réservation
  Future<bool> cancelBooking(String tripId, int seatsToCancel) async {
    return await _dbHelper.cancelBooking(tripId, _currentUserId);
  }

  // Obtenir les trajets réservés par l'utilisateur actuel
  Future<List<TripModel>> getMyBookedTrips() async {
    return await _dbHelper.getBookedTripsByUser(_currentUserId);
  }

  // Vérifier si l'utilisateur a réservé un trajet
  Future<bool> hasUserBookedTrip(String tripId) async {
    return await _dbHelper.hasUserBookedTrip(tripId, _currentUserId);
  }

  // Initialiser avec des données de test (déjà fait dans DatabaseHelper)
  Future<void> initializeSampleData() async {
    // Les données sont déjà initialisées lors de la création de la base
    // Cette méthode est conservée pour la compatibilité
    final trips = await getAllTrips();
    if (trips.isEmpty) {
      // Si la base est vide, la recréer
      await _dbHelper.resetDatabase();
    }
  }
}
*/



/*
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridesharing/common/model/trip_model.dart';

class TripService {
  static const String _tripsKey = 'trips_list';
  static const String _currentUserId = 'current_user_id'; // Simuler un utilisateur connecté

  // Obtenir tous les trajets
  Future<List<TripModel>> getAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tripsJson = prefs.getString(_tripsKey);
    if (tripsJson == null) {
      return [];
    }
    final List<dynamic> decodedList = json.decode(tripsJson);
    return decodedList.map((item) => TripModel.fromJson(item)).toList();
  }

  // Sauvegarder tous les trajets
  Future<void> _saveTrips(List<TripModel> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final String tripsJson = json.encode(trips.map((trip) => trip.toJson()).toList());
    await prefs.setString(_tripsKey, tripsJson);
  }

  // Ajouter un trajet
  Future<void> addTrip(TripModel trip) async {
    final trips = await getAllTrips();
    trips.add(trip);
    await _saveTrips(trips);
  }

  // Mettre à jour un trajet
  Future<void> updateTrip(TripModel updatedTrip) async {
    final trips = await getAllTrips();
    final index = trips.indexWhere((trip) => trip.id == updatedTrip.id);
    if (index != -1) {
      trips[index] = updatedTrip;
      await _saveTrips(trips);
    }
  }

  // Supprimer un trajet
  Future<void> deleteTrip(String tripId) async {
    final trips = await getAllTrips();
    trips.removeWhere((trip) => trip.id == tripId);
    await _saveTrips(trips);
  }

  // Rechercher des trajets
  Future<List<TripModel>> searchTrips(String from, String to) async {
    final trips = await getAllTrips();
    return trips.where((trip) {
      final fromMatch = from.isEmpty || trip.from.toLowerCase().contains(from.toLowerCase());
      final toMatch = to.isEmpty || trip.to.toLowerCase().contains(to.toLowerCase());
      return fromMatch && toMatch && trip.availableSeats > 0;
    }).toList();
  }

  // Réserver un trajet
  Future<bool> bookTrip(String tripId, int seatsToBook) async {
    final trips = await getAllTrips();
    final index = trips.indexWhere((trip) => trip.id == tripId);
    if (index == -1) return false;
    final trip = trips[index];
    if (trip.availableSeats < seatsToBook) {
      return false; // Pas assez de places disponibles
    }
    // Mettre à jour le nombre de places disponibles et bookedBy correctement
    final updatedTrip = trip.copyWith(
      availableSeats: trip.availableSeats - seatsToBook,
      // spread operator pour concatener la liste existante + nouvel id
      bookedBy: [...trip.bookedBy, _currentUserId],
    );
    trips[index] = updatedTrip;
    await _saveTrips(trips);
    return true;
  }

  // Annuler une réservation
  Future<bool> cancelBooking(String tripId, int seatsToCancel) async {
    final trips = await getAllTrips();
    final index = trips.indexWhere((trip) => trip.id == tripId);
    if (index == -1) return false;
    final trip = trips[index];
    // Vérifier que l'utilisateur a bien réservé ce trajet
    if (!trip.bookedBy.contains(_currentUserId)) {
      return false;
    }
    // Mettre à jour le nombre de places disponibles
    final updatedBookedBy = List<String>.from(trip.bookedBy);
    updatedBookedBy.remove(_currentUserId);
    final updatedTrip = trip.copyWith(
      availableSeats: trip.availableSeats + seatsToCancel,
      bookedBy: updatedBookedBy,
    );
    trips[index] = updatedTrip;
    await _saveTrips(trips);
    return true;
  }

  // Obtenir les trajets réservés par l'utilisateur actuel
  Future<List<TripModel>> getMyBookedTrips() async {
    final trips = await getAllTrips();
    return trips.where((trip) => trip.bookedBy.contains(_currentUserId)).toList();
  }

  // Initialiser avec des données de test
  Future<void> initializeSampleData() async {
    final trips = await getAllTrips();
    if (trips.isEmpty) {
      final sampleTrips = [
        TripModel(
          id: '1',
          from: 'Tunis',
          to: 'Sousse',
          driverName: 'Ahmed Ben Ali',
          driverPhone: '+216 20 123 456',
          departureTime: DateTime.now().add(Duration(hours: 2)),
          availableSeats: 3,
          totalSeats: 4,
          pricePerSeat: 15.0,
          vehicleType: 'Car',
        ),
        TripModel(
          id: '2',
          from: 'Tunis',
          to: 'Sfax',
          driverName: 'Fatma Mansour',
          driverPhone: '+216 22 234 567',
          departureTime: DateTime.now().add(Duration(hours: 4)),
          availableSeats: 2,
          totalSeats: 3,
          pricePerSeat: 25.0,
          vehicleType: 'Bike',
        ),
        TripModel(
          id: '3',
          from: 'Sousse',
          to: 'Monastir',
          driverName: 'Mohamed Trabelsi',
          driverPhone: '+216 24 345 678',
          departureTime: DateTime.now().add(Duration(days: 1)),
          availableSeats: 4,
          totalSeats: 4,
          pricePerSeat: 8.0,
          vehicleType: 'Taxi',
        ),
      ];
      await _saveTrips(sampleTrips);
    }
  }
}
*/












/*
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridesharing/common/model/trip_model.dart';

class TripService {
  static const String _tripsKey = 'trips_list';
  static const String _currentUserId = 'current_user_id'; // Simuler un utilisateur connecté

  // Obtenir tous les trajets
  Future<List<TripModel>> getAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tripsJson = prefs.getString(_tripsKey);
    
    if (tripsJson == null) {
      return [];
    }
    
    final List<dynamic> decodedList = json.decode(tripsJson);
    return decodedList.map((item) => TripModel.fromJson(item)).toList();
  }

  // Sauvegarder tous les trajets
  Future<void> _saveTrips(List<TripModel> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final String tripsJson = json.encode(trips.map((trip) => trip.toJson()).toList());
    await prefs.setString(_tripsKey, tripsJson);
  }

  // Ajouter un trajet
  Future<void> addTrip(TripModel trip) async {
    final trips = await getAllTrips();
    trips.add(trip);
    await _saveTrips(trips);
  }

  // Mettre à jour un trajet
  Future<void> updateTrip(TripModel updatedTrip) async {
    final trips = await getAllTrips();
    final index = trips.indexWhere((trip) => trip.id == updatedTrip.id);
    
    if (index != -1) {
      trips[index] = updatedTrip;
      await _saveTrips(trips);
    }
  }

  // Supprimer un trajet
  Future<void> deleteTrip(String tripId) async {
    final trips = await getAllTrips();
    trips.removeWhere((trip) => trip.id == tripId);
    await _saveTrips(trips);
  }

  // Rechercher des trajets
  Future<List<TripModel>> searchTrips(String from, String to) async {
    final trips = await getAllTrips();
    
    return trips.where((trip) {
      final fromMatch = from.isEmpty || 
          trip.from.toLowerCase().contains(from.toLowerCase());
      final toMatch = to.isEmpty || 
          trip.to.toLowerCase().contains(to.toLowerCase());
      
      return fromMatch && toMatch && trip.availableSeats > 0;
    }).toList();
  }

  // Réserver un trajet
  Future<bool> bookTrip(String tripId, int seatsToBook) async {
    final trips = await getAllTrips();
    final index = trips.indexWhere((trip) => trip.id == tripId);
    
    if (index == -1) return false;
    
    final trip = trips[index];
    
    if (trip.availableSeats < seatsToBook) {
      return false; // Pas assez de places disponibles
    }
    
    // Mettre à jour le nombre de places disponibles
    final updatedTrip = trip.copyWith(
      availableSeats: trip.availableSeats - seatsToBook,
      bookedBy: [...trip.bookedBy, _currentUserId],
    );
    
    trips[index] = updatedTrip;
    await _saveTrips(trips);
    
    return true;
  }

  // Annuler une réservation
  Future<bool> cancelBooking(String tripId, int seatsToCancel) async {
    final trips = await getAllTrips();
    final index = trips.indexWhere((trip) => trip.id == tripId);
    
    if (index == -1) return false;
    
    final trip = trips[index];
    
    // Vérifier que l'utilisateur a bien réservé ce trajet
    if (!trip.bookedBy.contains(_currentUserId)) {
      return false;
    }
    
    // Mettre à jour le nombre de places disponibles
    final updatedBookedBy = List<String>.from(trip.bookedBy);
    updatedBookedBy.remove(_currentUserId);
    
    final updatedTrip = trip.copyWith(
      availableSeats: trip.availableSeats + seatsToCancel,
      bookedBy: updatedBookedBy,
    );
    
    trips[index] = updatedTrip;
    await _saveTrips(trips);
    
    return true;
  }

  // Obtenir les trajets réservés par l'utilisateur actuel
  Future<List<TripModel>> getMyBookedTrips() async {
    final trips = await getAllTrips();
    return trips.where((trip) => trip.bookedBy.contains(_currentUserId)).toList();
  }

  // Initialiser avec des données de test
  Future<void> initializeSampleData() async {
    final trips = await getAllTrips();
    
    if (trips.isEmpty) {
      final sampleTrips = [
        TripModel(
          id: '1',
          from: 'Tunis',
          to: 'Sousse',
          driverName: 'Ahmed Ben Ali',
          driverPhone: '+216 20 123 456',
          departureTime: DateTime.now().add(Duration(hours: 2)),
          availableSeats: 3,
          totalSeats: 4,
          pricePerSeat: 15.0,
          vehicleType: 'Car',
        ),
        TripModel(
          id: '2',
          from: 'Tunis',
          to: 'Sfax',
          driverName: 'Fatma Mansour',
          driverPhone: '+216 22 234 567',
          departureTime: DateTime.now().add(Duration(hours: 4)),
          availableSeats: 2,
          totalSeats: 3,
          pricePerSeat: 25.0,
          vehicleType: 'Bike',
        ),
        TripModel(
          id: '3',
          from: 'Sousse',
          to: 'Monastir',
          driverName: 'Mohamed Trabelsi',
          driverPhone: '+216 24 345 678',
          departureTime: DateTime.now().add(Duration(days: 1)),
          availableSeats: 4,
          totalSeats: 4,
          pricePerSeat: 8.0,
          vehicleType: 'Taxi',
        ),
      ];
      
      await _saveTrips(sampleTrips);
    }
  }
}
*/