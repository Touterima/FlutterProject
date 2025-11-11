//lib/common/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ridesharing/common/model/trip_model.dart';

class DatabaseHelper {
  /*
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(join(await getDatabasesPath(), 'cart.db'),
        version: 1, onCreate: (db, version) {
      return db.execute(''' CREATE TABLE cart
           (
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           title TEXT ,
           description TEXT ,
           price REAL , )''');
    });
    return _db!;
  }
  */
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ridesharing.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table des trajets
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        from_city TEXT NOT NULL,
        to_city TEXT NOT NULL,
        driver_name TEXT NOT NULL,
        driver_phone TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        available_seats INTEGER NOT NULL,
        total_seats INTEGER NOT NULL,
        price_per_seat REAL NOT NULL,
        vehicle_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Table des réservations
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        seats_booked INTEGER NOT NULL,
        booking_date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    // Index pour améliorer les performances
    await db.execute('''
      CREATE INDEX idx_trips_from_to ON trips(from_city, to_city)
    ''');

    await db.execute('''
      CREATE INDEX idx_bookings_trip ON bookings(trip_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_bookings_user ON bookings(user_id)
    ''');

    // Insérer des données de test
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now();
    
    final sampleTrips = [
      {
        'id': '1',
        'from_city': 'Tunis',
        'to_city': 'Sousse',
        'driver_name': 'Ahmed Ben Ali',
        'driver_phone': '+216 20 123 456',
        'departure_time': now.add(Duration(hours: 2)).toIso8601String(),
        'available_seats': 3,
        'total_seats': 4,
        'price_per_seat': 15.0,
        'vehicle_type': 'Car',
        'created_at': now.toIso8601String(),
      },
      {
        'id': '2',
        'from_city': 'Tunis',
        'to_city': 'Sfax',
        'driver_name': 'Fatma Mansour',
        'driver_phone': '+216 22 234 567',
        'departure_time': now.add(Duration(hours: 4)).toIso8601String(),
        'available_seats': 2,
        'total_seats': 3,
        'price_per_seat': 25.0,
        'vehicle_type': 'Bike',
        'created_at': now.toIso8601String(),
      },
      {
        'id': '3',
        'from_city': 'Sousse',
        'to_city': 'Monastir',
        'driver_name': 'Mohamed Trabelsi',
        'driver_phone': '+216 24 345 678',
        'departure_time': now.add(Duration(days: 1)).toIso8601String(),
        'available_seats': 4,
        'total_seats': 4,
        'price_per_seat': 8.0,
        'vehicle_type': 'Taxi',
        'created_at': now.toIso8601String(),
      },
    ];

    for (var trip in sampleTrips) {
      await db.insert('trips', trip, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // CRUD pour les trajets
  
  // Créer un trajet
  Future<int> insertTrip(TripModel trip) async {
    final db = await database;
    return await db.insert(
      'trips',
      {
        'id': trip.id,
        'from_city': trip.from,
        'to_city': trip.to,
        'driver_name': trip.driverName,
        'driver_phone': trip.driverPhone,
        'departure_time': trip.departureTime.toIso8601String(),
        'available_seats': trip.availableSeats,
        'total_seats': trip.totalSeats,
        'price_per_seat': trip.pricePerSeat,
        'vehicle_type': trip.vehicleType,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lire tous les trajets
  Future<List<TripModel>> getAllTrips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      orderBy: 'departure_time ASC',
    );

    List<TripModel> trips = [];
    for (var map in maps) {
      // Récupérer les réservations pour ce trajet
      final bookings = await getBookingsForTrip(map['id']);
      
      trips.add(TripModel(
        id: map['id'],
        from: map['from_city'],
        to: map['to_city'],
        driverName: map['driver_name'],
        driverPhone: map['driver_phone'],
        departureTime: DateTime.parse(map['departure_time']),
        availableSeats: map['available_seats'],
        totalSeats: map['total_seats'],
        pricePerSeat: map['price_per_seat'],
        vehicleType: map['vehicle_type'],
        bookedBy: bookings.map((b) => b['user_id'] as String).toList(),
      ));
    }

    return trips;
  }

  // Rechercher des trajets
  Future<List<TripModel>> searchTrips(String from, String to) async {
    final db = await database;
    
    String whereClause = 'available_seats > 0';
    List<dynamic> whereArgs = [];
    
    if (from.isNotEmpty) {
      whereClause += ' AND from_city LIKE ?';
      whereArgs.add('%$from%');
    }
    
    if (to.isNotEmpty) {
      whereClause += ' AND to_city LIKE ?';
      whereArgs.add('%$to%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'departure_time ASC',
    );

    List<TripModel> trips = [];
    for (var map in maps) {
      final bookings = await getBookingsForTrip(map['id']);
      
      trips.add(TripModel(
        id: map['id'],
        from: map['from_city'],
        to: map['to_city'],
        driverName: map['driver_name'],
        driverPhone: map['driver_phone'],
        departureTime: DateTime.parse(map['departure_time']),
        availableSeats: map['available_seats'],
        totalSeats: map['total_seats'],
        pricePerSeat: map['price_per_seat'],
        vehicleType: map['vehicle_type'],
        bookedBy: bookings.map((b) => b['user_id'] as String).toList(),
      ));
    }

    return trips;
  }

  // Mettre à jour un trajet
  Future<int> updateTrip(TripModel trip) async {
    final db = await database;
    return await db.update(
      'trips',
      {
        'from_city': trip.from,
        'to_city': trip.to,
        'driver_name': trip.driverName,
        'driver_phone': trip.driverPhone,
        'departure_time': trip.departureTime.toIso8601String(),
        'available_seats': trip.availableSeats,
        'total_seats': trip.totalSeats,
        'price_per_seat': trip.pricePerSeat,
        'vehicle_type': trip.vehicleType,
      },
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  // Supprimer un trajet
  Future<int> deleteTrip(String tripId) async {
    final db = await database;
    // Les réservations seront supprimées automatiquement grâce à ON DELETE CASCADE
    return await db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  // CRUD pour les réservations

  // Créer une réservation
  Future<bool> bookTrip(String tripId, String userId, int seatsToBook) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // Vérifier les places disponibles
        final trip = await txn.query(
          'trips',
          where: 'id = ?',
          whereArgs: [tripId],
        );

        if (trip.isEmpty) {
          throw Exception('Trajet introuvable');
        }

        final availableSeats = trip.first['available_seats'] as int;
        
        if (availableSeats < seatsToBook) {
          throw Exception('Pas assez de places disponibles');
        }

        // Créer la réservation
        await txn.insert('bookings', {
          'trip_id': tripId,
          'user_id': userId,
          'seats_booked': seatsToBook,
          'booking_date': DateTime.now().toIso8601String(),
          'status': 'confirmed',
        });

        // Mettre à jour les places disponibles
        await txn.update(
          'trips',
          {'available_seats': availableSeats - seatsToBook},
          where: 'id = ?',
          whereArgs: [tripId],
        );
      });

      return true;
    } catch (e) {
      print('Erreur lors de la réservation: $e');
      return false;
    }
  }

  // Annuler une réservation
  Future<bool> cancelBooking(String tripId, String userId) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // Récupérer la réservation
        final bookings = await txn.query(
          'bookings',
          where: 'trip_id = ? AND user_id = ? AND status = ?',
          whereArgs: [tripId, userId, 'confirmed'],
        );

        if (bookings.isEmpty) {
          throw Exception('Réservation introuvable');
        }

        final seatsBooked = bookings.first['seats_booked'] as int;

        // Supprimer la réservation
        await txn.delete(
          'bookings',
          where: 'trip_id = ? AND user_id = ?',
          whereArgs: [tripId, userId],
        );

        // Restaurer les places disponibles
        await txn.rawUpdate(
          'UPDATE trips SET available_seats = available_seats + ? WHERE id = ?',
          [seatsBooked, tripId],
        );
      });

      return true;
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      return false;
    }
  }

  // Obtenir les réservations pour un trajet
  Future<List<Map<String, dynamic>>> getBookingsForTrip(String tripId) async {
    final db = await database;
    return await db.query(
      'bookings',
      where: 'trip_id = ? AND status = ?',
      whereArgs: [tripId, 'confirmed'],
    );
  }

  // Obtenir les trajets réservés par un utilisateur
  Future<List<TripModel>> getBookedTripsByUser(String userId) async {
    final db = await database;
    
    final results = await db.rawQuery('''
      SELECT t.* FROM trips t
      INNER JOIN bookings b ON t.id = b.trip_id
      WHERE b.user_id = ? AND b.status = ?
      ORDER BY t.departure_time ASC
    ''', [userId, 'confirmed']);

    List<TripModel> trips = [];
    for (var map in results) {
      final bookings = await getBookingsForTrip(map['id'] as String);
      
      trips.add(TripModel(
        id: map['id'] as String,
        from: map['from_city'] as String,
        to: map['to_city'] as String,
        driverName: map['driver_name'] as String,
        driverPhone: map['driver_phone'] as String,
        departureTime: DateTime.parse(map['departure_time'] as String),
        availableSeats: map['available_seats'] as int,
        totalSeats: map['total_seats'] as int,
        pricePerSeat: map['price_per_seat'] as double,
        vehicleType: map['vehicle_type'] as String,
        bookedBy: bookings.map((b) => b['user_id'] as String).toList(),
      ));
    }

    return trips;
  }

  // Vérifier si l'utilisateur a réservé un trajet
  Future<bool> hasUserBookedTrip(String tripId, String userId) async {
    final db = await database;
    final result = await db.query(
      'bookings',
      where: 'trip_id = ? AND user_id = ? AND status = ?',
      whereArgs: [tripId, userId, 'confirmed'],
    );
    return result.isNotEmpty;
  }

  // Fermer la base de données
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Réinitialiser la base de données (pour le développement)
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ridesharing.db');
    await deleteDatabase(path);
    _database = null;
    await database; // Réinitialiser
  }
}