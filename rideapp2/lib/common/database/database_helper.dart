//lib/common/database/database_helper.dart
import 'package:flutter/foundation.dart';
import 'package:ridesharing/common/model/event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user_model.dart';
import 'package:ridesharing/common/model/trip_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rideapp.db');
    return await openDatabase(
      path,
      version: 7, // Version incrémentée pour ajouter les tables trips
      onCreate: (db, version) async {
        await _createDatabase(db, version);
        await _createPasswordRecoveryTable(db);
        await _createEventsTables(db);
        await _createTripsTables(db); // AJOUT: Création des tables trips
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN avatarInitials TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN registrationIp TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN registrationCountry TEXT');
        }
        if (oldVersion < 3) {
          await _createPasswordRecoveryTable(db);
        }
        if (oldVersion < 4) {
          await _recreateUsersTable(db);
        }
        if (oldVersion < 5) {
          await _createEventsTables(db);
        }
        if (oldVersion < 6) {
          await _fixEventsTableColumn(db);
        }
        if (oldVersion < 7) {
          await _createTripsTables(db); // AJOUT: Migration pour les tables trips
        }
      },
    );
  }

  // AJOUT: Méthode pour créer les tables trips et bookings
  Future<void> _createTripsTables(Database db) async {
    // Table des trajets
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trips(
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
      CREATE TABLE IF NOT EXISTS bookings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        seats_booked INTEGER NOT NULL,
        booking_date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
        UNIQUE(trip_id, user_id)
      )
    ''');

    if (kDebugMode) {
      print("✅ Tables trips et bookings créées avec succès");
    }
  }

  Future<void> _fixEventsTableColumn(Database db) async {
    try {
      final columns = await db.rawQuery("PRAGMA table_info(events)");
      final hasOddObjective = columns.any((col) => col['name'] == 'oddObjective');
      final hasOddObjectives = columns.any((col) => col['name'] == 'oddObjectives');
      
      if (hasOddObjective && !hasOddObjectives) {
        if (kDebugMode) {
          print("🔄 Correction du nom de colonne: oddObjective → oddObjectives");
        }
        
        await db.execute('''
          CREATE TABLE events_temp(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            location TEXT NOT NULL,
            oddObjectives TEXT NOT NULL,
            date TEXT NOT NULL,
            image TEXT,
            category TEXT,
            price INTEGER,
            creationAt TEXT,
            updatedAt TEXT,
            userId INTEGER NOT NULL,
            likeCount INTEGER DEFAULT 0,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        
        await db.execute('''
          INSERT INTO events_temp 
          (id, title, description, location, oddObjectives, date, image, category, price, creationAt, updatedAt, userId, likeCount)
          SELECT id, title, description, location, oddObjective, date, image, category, price, creationAt, updatedAt, userId, likeCount 
          FROM events
        ''');
        
        await db.execute('DROP TABLE events');
        await db.execute('ALTER TABLE events_temp RENAME TO events');
        
        if (kDebugMode) {
          print("✅ Nom de colonne corrigé avec succès");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur lors de la correction de la colonne: $e");
      }
    }
  }

  Future<void> _recreateUsersTable(Database db) async {
    final List<Map<String, dynamic>> oldUsers = await db.query('users');
    
    await db.execute('DROP TABLE IF EXISTS users');
    
    await _createDatabase(db, 4);
    
    for (var user in oldUsers) {
      await db.insert('users', {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'phoneNumber': user['phoneNumber'],
        'gender': user['gender'],
        'password': user['password'],
        'avatarInitials': user['avatarInitials'],
        'registrationIp': user['registrationIp'],
        'registrationCountry': user['registrationCountry'],
      });
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phoneNumber TEXT NOT NULL,
        gender TEXT NOT NULL,
        password TEXT NOT NULL,
        avatarInitials TEXT,
        registrationIp TEXT,  
        registrationCountry TEXT
      )
    ''');
  }

  Future<void> _createPasswordRecoveryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS password_recovery(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        code TEXT NOT NULL,
        expiration TEXT NOT NULL,
        used INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _createEventsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        oddObjectives TEXT NOT NULL,
        date TEXT NOT NULL,
        image TEXT,
        category TEXT,
        price INTEGER,
        creationAt TEXT,
        updatedAt TEXT,
        userId INTEGER NOT NULL,
        likeCount INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS event_likes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(eventId, userId)
      )
    ''');
  }

  // CRUD Operations for Users
  Future<int> insertUser(User user) async {
    final db = await database;
    try {
      final normalizedUser = User(
        id: user.id,
        name: user.name,
        email: _normalizeEmail(user.email),
        phoneNumber: user.phoneNumber,
        gender: user.gender,
        password: user.password,
        avatarInitials: user.avatarInitials,
        registrationIp: user.registrationIp,
        registrationCountry: user.registrationCountry,
      );
      
      final result = await db.insert('users', normalizedUser.toMap());
      if (kDebugMode) {
        print("✅ Utilisateur inséré: ${normalizedUser.email} (ID: $result)");
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur insertion: $e");
      }
      rethrow;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final normalizedEmail = _normalizeEmail(email);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    final normalizedUser = User(
      id: user.id,
      name: user.name,
      email: _normalizeEmail(user.email),
      phoneNumber: user.phoneNumber,
      gender: user.gender,
      password: user.password,
      avatarInitials: user.avatarInitials,
      registrationIp: user.registrationIp,
      registrationCountry: user.registrationCountry,
    );
    
    return await db.update(
      'users',
      normalizedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> checkUserCredentials(String email, String password) async {
    final db = await database;
    final normalizedEmail = _normalizeEmail(email);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
    );
    return maps.isNotEmpty;
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final normalizedEmail = _normalizeEmail(email);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    return maps.isNotEmpty;
  }

  String _normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  Future<void> fixDuplicateEmails() async {
    final db = await database;
    
    final duplicates = await db.rawQuery('''
      SELECT email, COUNT(*) as count 
      FROM users 
      GROUP BY LOWER(TRIM(email)) 
      HAVING COUNT(*) > 1
    ''');
    
    if (duplicates.isNotEmpty) {
      await db.execute('''
        DELETE FROM users 
        WHERE id NOT IN (
          SELECT MIN(id) 
          FROM users 
          GROUP BY LOWER(TRIM(email))
        )
      ''');
    }
  }

  Future<void> debugPrintAllUsers() async {
    final users = await getAllUsers();
    if (kDebugMode) {
      print("=== 🗂️ LISTE COMPLÈTE DES UTILISATEURS ===");
      print("📊 Total: ${users.length} utilisateur(s)");
      for (var user in users) {
        print("👤 ID: ${user.id} - ${user.name} (${user.email})");
      }
      print("=== FIN DE LA LISTE ===");
    }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS bookings');
    await db.execute('DROP TABLE IF EXISTS trips');
    await db.execute('DROP TABLE IF EXISTS event_likes');
    await db.execute('DROP TABLE IF EXISTS events');
    await db.execute('DROP TABLE IF EXISTS password_recovery');
    await db.execute('DROP TABLE IF EXISTS users');
    await _createDatabase(db, 7);
    await _createPasswordRecoveryTable(db);
    await _createEventsTables(db);
    await _createTripsTables(db);
    if (kDebugMode) {
      print("🗑️ Base de données complètement réinitialisée");
    }
  }

  // EVENT CRUD OPERATIONS
  Future<int> insertEvent(Event event) async {
    final db = await database;
    try {
      final eventMap = {
        'title': event.title,
        'description': event.description,
        'location': event.location,
        'oddObjectives': event.oddObjectives.join('|'),
        'date': event.date,
        'image': event.image,
        'category': event.category,
        'price': event.price,
        'creationAt': event.creationAt,
        'updatedAt': event.updatedAt,
        'userId': event.userId,
        'likeCount': event.likeCount,
      };
      
      final result = await db.insert('events', eventMap);
      if (kDebugMode) {
        print("✅ Event inserted: ${event.title} (ID: $result)");
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error inserting event: $e");
      }
      rethrow;
    }
  }

  Future<List<Event>> getAllEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<List<Event>> getUserEvents(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<Event?> getEventById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEvent(Event event, int currentUserId) async {
    if (!event.isOwner(currentUserId)) {
      throw Exception("Unauthorized: You can only update your own events");
    }
    
    final db = await database;
    
    final eventMap = {
      'title': event.title,
      'description': event.description,
      'location': event.location,
      'oddObjectives': event.oddObjectives.join('|'),
      'date': event.date,
      'image': event.image,
      'category': event.category,
      'price': event.price,
      'updatedAt': event.updatedAt,
      'userId': event.userId,
      'likeCount': event.likeCount,
    };
    
    return await db.update(
      'events',
      eventMap,
      where: 'id = ? AND userId = ?',
      whereArgs: [event.id, currentUserId],
    );
  }

  Future<int> deleteEvent(int id, int currentUserId) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, currentUserId],
    );
  }

  Future<bool> isEventOwner(int eventId, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    return maps.isNotEmpty;
  }

  // EVENT LIKES OPERATIONS
  Future<int> likeEvent(int eventId, int userId) async {
    final db = await database;
    
    final existingLike = await db.query(
      'event_likes',
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    
    if (existingLike.isEmpty) {
      await db.insert('event_likes', {
        'eventId': eventId,
        'userId': userId,
        'createdAt': DateTime.now().toString(),
      });
      
      await db.rawUpdate(
        'UPDATE events SET likeCount = likeCount + 1 WHERE id = ?',
        [eventId]
      );
      
      return 1;
    }
    return 0;
  }

  Future<int> unlikeEvent(int eventId, int userId) async {
    final db = await database;
    
    final result = await db.delete(
      'event_likes',
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    
    if (result > 0) {
      await db.rawUpdate(
        'UPDATE events SET likeCount = likeCount - 1 WHERE id = ?',
        [eventId]
      );
    }
    
    return result;
  }

  Future<bool> isEventLikedByUser(int eventId, int userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'event_likes',
        where: 'eventId = ? AND userId = ?',
        whereArgs: [eventId, userId],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<Event>> getAllEventsWithLikes(int? userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    
    return await Future.wait(maps.map((map) async {
      final event = Event.fromMap(map);
      
      if (userId != null) {
        final isLiked = await isEventLikedByUser(event.id!, userId);
        return event.copyWith(isLiked: isLiked);
      }
      
      return event;
    }));
  }

  Future<int> getEventLikeCount(int eventId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM event_likes WHERE eventId = ?',
        [eventId]
      );
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Event>> getLikedEvents(int userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT e.* FROM events e
        INNER JOIN event_likes el ON e.id = el.eventId
        WHERE el.userId = ?
        ORDER BY el.createdAt DESC
      ''', [userId]);
      
      return await Future.wait(maps.map((map) async {
        final event = Event.fromMap(map);
        final isLiked = await isEventLikedByUser(event.id!, userId);
        return event.copyWith(isLiked: isLiked);
      }));
    } catch (e) {
      return [];
    }
  }

  // Password Recovery Operations
  Future<int> insertPasswordRecoveryCode(String email, String code, DateTime expiration) async {
    final db = await database;
    return await db.insert('password_recovery', {
      'email': email,
      'code': code,
      'expiration': expiration.toIso8601String(),
      'used': 0,
    });
  }

  Future<Map<String, dynamic>?> getValidRecoveryCode(String email, String code) async {
    final db = await database;
    final result = await db.query(
      'password_recovery',
      where: 'email = ? AND code = ? AND used = 0 AND expiration > ?',
      whereArgs: [email, code, DateTime.now().toIso8601String()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> markRecoveryCodeAsUsed(String email, String code) async {
    final db = await database;
    return await db.update(
      'password_recovery',
      {'used': 1},
      where: 'email = ? AND code = ?',
      whereArgs: [email, code],
    );
  }

  Future<void> cleanupExpiredRecoveryCodes() async {
    final db = await database;
    await db.delete(
      'password_recovery',
      where: 'expiration < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  // ==================== TRIPS CRUD OPERATIONS ====================
  
  Future<int> insertTrip(TripModel trip) async {
    final db = await database;
    try {
      final result = await db.insert(
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
      
      if (kDebugMode) {
        print("✅ Trajet ajouté: ${trip.from} → ${trip.to} (ID: ${trip.id})");
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur lors de l'ajout du trajet: $e");
      }
      rethrow;
    }
  }

  Future<List<TripModel>> getAllTrips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
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

  Future<int> deleteTrip(String tripId) async {
    final db = await database;
    return await db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  // ==================== BOOKINGS CRUD OPERATIONS ====================

  Future<bool> bookTrip(String tripId, String userId, int seatsToBook) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
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

        await txn.insert('bookings', {
          'trip_id': tripId,
          'user_id': userId,
          'seats_booked': seatsToBook,
          'booking_date': DateTime.now().toIso8601String(),
          'status': 'confirmed',
        });

        await txn.update(
          'trips',
          {'available_seats': availableSeats - seatsToBook},
          where: 'id = ?',
          whereArgs: [tripId],
        );
      });

      if (kDebugMode) {
        print("✅ Réservation confirmée: $seatsToBook place(s) pour le trajet $tripId");
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la réservation: $e');
      }
      return false;
    }
  }

  Future<bool> cancelBooking(String tripId, String userId) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        final bookings = await txn.query(
          'bookings',
          where: 'trip_id = ? AND user_id = ? AND status = ?',
          whereArgs: [tripId, userId, 'confirmed'],
        );

        if (bookings.isEmpty) {
          throw Exception('Réservation introuvable');
        }

        final seatsBooked = bookings.first['seats_booked'] as int;

        await txn.delete(
          'bookings',
          where: 'trip_id = ? AND user_id = ?',
          whereArgs: [tripId, userId],
        );

        await txn.rawUpdate(
          'UPDATE trips SET available_seats = available_seats + ? WHERE id = ?',
          [seatsBooked, tripId],
        );
      });

      if (kDebugMode) {
        print("✅ Réservation annulée pour le trajet $tripId");
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'annulation: $e');
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getBookingsForTrip(String tripId) async {
    final db = await database;
    return await db.query(
      'bookings',
      where: 'trip_id = ? AND status = ?',
      whereArgs: [tripId, 'confirmed'],
    );
  }

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

  Future<bool> hasUserBookedTrip(String tripId, String userId) async {
    final db = await database;
    final result = await db.query(
      'bookings',
      where: 'trip_id = ? AND user_id = ? AND status = ?',
      whereArgs: [tripId, userId, 'confirmed'],
    );
    return result.isNotEmpty;
  }

  // Check if database tables exist (for debugging)
  Future<void> checkDatabaseTables() async {
    final db = await database;
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      if (kDebugMode) {
        print("📊 Database tables:");
        for (var table in tables) {
          print(" - ${table['name']}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error checking database tables: $e");
      }
    }
  }

  // Fermer la base de données
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

/*
import 'package:flutter/foundation.dart';
import 'package:ridesharing/common/model/event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user_model.dart';
import 'package:ridesharing/common/model/trip_model.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rideapp.db');
    return await openDatabase(
      path,
      version: 6, // Version incrémentée pour la correction
      onCreate: (db, version) async {
        await _createDatabase(db, version);
        await _createPasswordRecoveryTable(db);
        await _createEventsTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN avatarInitials TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN registrationIp TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN registrationCountry TEXT');
        }
        if (oldVersion < 3) {
          await _createPasswordRecoveryTable(db);
        }
        if (oldVersion < 4) {
          await _recreateUsersTable(db);
        }
        if (oldVersion < 5) {
          await _createEventsTables(db);
        }
        if (oldVersion < 6) {
          await _fixEventsTableColumn(db); // CORRECTION DU NOM DE COLONNE
        }
      },
    );
  }

  // MÉTHODE POUR CORRIGER LE NOM DE COLONNE
  Future<void> _fixEventsTableColumn(Database db) async {
    try {
      // Vérifier si la colonne oddObjective existe (ancien nom)
      final columns = await db.rawQuery("PRAGMA table_info(events)");
      final hasOddObjective = columns.any((col) => col['name'] == 'oddObjective');
      final hasOddObjectives = columns.any((col) => col['name'] == 'oddObjectives');
      
      if (hasOddObjective && !hasOddObjectives) {
        if (kDebugMode) {
          print("🔄 Correction du nom de colonne: oddObjective → oddObjectives");
        }
        
        // Créer une table temporaire avec le bon nom de colonne
        await db.execute('''
          CREATE TABLE events_temp(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            location TEXT NOT NULL,
            oddObjectives TEXT NOT NULL,
            date TEXT NOT NULL,
            image TEXT,
            category TEXT,
            price INTEGER,
            creationAt TEXT,
            updatedAt TEXT,
            userId INTEGER NOT NULL,
            likeCount INTEGER DEFAULT 0,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        
        // Copier les données de l'ancienne table vers la nouvelle
        await db.execute('''
          INSERT INTO events_temp 
          (id, title, description, location, oddObjectives, date, image, category, price, creationAt, updatedAt, userId, likeCount)
          SELECT id, title, description, location, oddObjective, date, image, category, price, creationAt, updatedAt, userId, likeCount 
          FROM events
        ''');
        
        // Supprimer l'ancienne table
        await db.execute('DROP TABLE events');
        
        // Renommer la table temporaire
        await db.execute('ALTER TABLE events_temp RENAME TO events');
        
        if (kDebugMode) {
          print("✅ Nom de colonne corrigé avec succès");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur lors de la correction de la colonne: $e");
      }
    }
  }

  Future<void> _recreateUsersTable(Database db) async {
    final List<Map<String, dynamic>> oldUsers = await db.query('users');
    
    await db.execute('DROP TABLE IF EXISTS users');
    
    await _createDatabase(db, 4);
    
    for (var user in oldUsers) {
      await db.insert('users', {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'phoneNumber': user['phoneNumber'],
        'gender': user['gender'],
        'password': user['password'],
        'avatarInitials': user['avatarInitials'],
        'registrationIp': user['registrationIp'],
        'registrationCountry': user['registrationCountry'],
      });
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phoneNumber TEXT NOT NULL,
        gender TEXT NOT NULL,
        password TEXT NOT NULL,
        avatarInitials TEXT,
        registrationIp TEXT,  
        registrationCountry TEXT
      )
    ''');
  }

  Future<void> _createPasswordRecoveryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS password_recovery(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        code TEXT NOT NULL,
        expiration TEXT NOT NULL,
        used INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _createEventsTables(Database db) async {
    // Create events table avec le BON nom de colonne
    await db.execute('''
      CREATE TABLE IF NOT EXISTS events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        oddObjectives TEXT NOT NULL,  /* CORRIGÉ : oddObjectives au pluriel */
        date TEXT NOT NULL,
        image TEXT,
        category TEXT,
        price INTEGER,
        creationAt TEXT,
        updatedAt TEXT,
        userId INTEGER NOT NULL,
        likeCount INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    
    // Create event_likes table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS event_likes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(eventId, userId)
      )
    ''');
  }

  // CRUD Operations for Users
  Future<int> insertUser(User user) async {
    final db = await database;
    try {
      final normalizedUser = User(
        id: user.id,
        name: user.name,
        email: _normalizeEmail(user.email),
        phoneNumber: user.phoneNumber,
        gender: user.gender,
        password: user.password,
        avatarInitials: user.avatarInitials,
        registrationIp: user.registrationIp,
        registrationCountry: user.registrationCountry,
      );
      
      final result = await db.insert('users', normalizedUser.toMap());
      if (kDebugMode) {
        print("✅ Utilisateur inséré: ${normalizedUser.email} (ID: $result)");
        print("🎨 Initiales: ${normalizedUser.avatarInitials}");
        print("🌍 Pays: ${normalizedUser.registrationCountry}");
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur insertion: $e");
      }
      rethrow;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final normalizedEmail = _normalizeEmail(email);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    final normalizedUser = User(
      id: user.id,
      name: user.name,
      email: _normalizeEmail(user.email),
      phoneNumber: user.phoneNumber,
      gender: user.gender,
      password: user.password,
      avatarInitials: user.avatarInitials,
      registrationIp: user.registrationIp,
      registrationCountry: user.registrationCountry,
    );
    
    return await db.update(
      'users',
      normalizedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> checkUserCredentials(String email, String password) async {
    final db = await database;
    final normalizedEmail = _normalizeEmail(email);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
    );
    return maps.isNotEmpty;
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final normalizedEmail = _normalizeEmail(email);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (kDebugMode) {
      print("🔍 Vérification email: '$email' → '$normalizedEmail' → ${maps.isNotEmpty ? 'EXISTE' : 'NEXISTE PAS'}");
    }
    return maps.isNotEmpty;
  }

  // Méthode pour normaliser les emails
  String _normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  // Méthode pour nettoyer les doublons d'emails
  Future<void> fixDuplicateEmails() async {
    final db = await database;
    
    final duplicates = await db.rawQuery('''
      SELECT email, COUNT(*) as count 
      FROM users 
      GROUP BY LOWER(TRIM(email)) 
      HAVING COUNT(*) > 1
    ''');
    
    if (kDebugMode) {
      print("🧹 Doublons trouvés: ${duplicates.length}");
      for (var dup in duplicates) {
        print(" - ${dup['email']} (${dup['count']} fois)");
      }
    }
    
    if (duplicates.isNotEmpty) {
      await db.execute('''
        DELETE FROM users 
        WHERE id NOT IN (
          SELECT MIN(id) 
          FROM users 
          GROUP BY LOWER(TRIM(email))
        )
      ''');
      
      if (kDebugMode) {
        print("✅ Base de données nettoyée - Doublons supprimés");
      }
    } else {
      if (kDebugMode) {
        print("✅ Aucun doublon trouvé");
      }
    }
  }

  // Méthode pour voir tous les utilisateurs (debug)
  Future<void> debugPrintAllUsers() async {
    final users = await getAllUsers();
    if (kDebugMode) {
      print("=== 🗂️ LISTE COMPLÈTE DES UTILISATEURS ===");
      print("📊 Total: ${users.length} utilisateur(s)");
      for (var user in users) {
        print("👤 ID: ${user.id}");
        print("   ├─ Nom: ${user.name}");
        print("   ├─ Email: ${user.email}");
        print("   ├─ Téléphone: ${user.phoneNumber}");
        print("   ├─ Genre: ${user.gender}");
        print("   ├─ Initiales: ${user.avatarInitials ?? 'Non défini'}");
        print("   ├─ IP: ${user.registrationIp ?? 'Non défini'}");
        print("   ├─ Pays: ${user.registrationCountry ?? 'Non défini'}");
        print("   └─ Mot de passe: ${user.password}");
      }
      print("=== FIN DE LA LISTE ===");
    }
  }

  // Méthode pour réinitialiser la base de données (attention!)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS event_likes');
    await db.execute('DROP TABLE IF EXISTS events');
    await db.execute('DROP TABLE IF EXISTS password_recovery');
    await db.execute('DROP TABLE IF EXISTS users');
    await _createDatabase(db, 4);
    await _createPasswordRecoveryTable(db);
    await _createEventsTables(db);
    if (kDebugMode) {
      print("🗑️ Base de données complètement réinitialisée");
    }
  }

  Future<void> completeResetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS password_recovery');
    await db.execute('DROP TABLE IF EXISTS events');
    await db.execute('DROP TABLE IF EXISTS event_likes');
    await _createDatabase(db, 4);
    await _createPasswordRecoveryTable(db);
    await _createEventsTables(db);
    if (kDebugMode) {
      print("🗑️ Base de données complètement réinitialisée");
    }
  }

  Future<void> migrateToNewSchema() async {
    try {
      final db = await database;
      
      await db.execute('''
        CREATE TABLE users_temp(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          phoneNumber TEXT NOT NULL,
          gender TEXT NOT NULL,
          password TEXT NOT NULL,
          avatarInitials TEXT,
          registrationIp TEXT,
          registrationCountry TEXT
        )
      ''');
      
      await db.execute('''
        INSERT INTO users_temp (id, name, email, phoneNumber, gender, password, avatarInitials, registrationIp, registrationCountry)
        SELECT id, name, email, phoneNumber, gender, password, NULL, NULL, NULL FROM users
      ''');
      
      await db.execute('DROP TABLE users');
      
      await db.execute('ALTER TABLE users_temp RENAME TO users');
      
      debugPrint("✅ Migration de la base de données réussie!");
    } catch (e) {
      debugPrint("❌ Erreur migration: $e");
    }
  }

  // EVENT CRUD OPERATIONS - CORRECTION COMPLÈTE
  Future<int> insertEvent(Event event) async {
    final db = await database;
    try {
      // Créer une map avec les BONS noms de colonnes
      final eventMap = {
        'title': event.title,
        'description': event.description,
        'location': event.location,
        'oddObjectives': event.oddObjectives.join('|'), // CORRIGÉ : oddObjectives
        'date': event.date,
        'image': event.image,
        'category': event.category,
        'price': event.price,
        'creationAt': event.creationAt,
        'updatedAt': event.updatedAt,
        'userId': event.userId,
        'likeCount': event.likeCount,
      };
      
      final result = await db.insert('events', eventMap);
      if (kDebugMode) {
        print("✅ Event inserted: ${event.title} (ID: $result, User: ${event.userId})");
        print("📋 SDGs: ${event.oddObjectives.join(', ')}");
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error inserting event: $e");
        // Afficher plus de détails sur l'erreur
        print("📋 Error details: $e");
        
        // Vérifier la structure de la table pour debug
        await _debugEventsTableStructure();
      }
      rethrow;
    }
  }

  // Méthode de debug pour voir la structure de la table events
  Future<void> _debugEventsTableStructure() async {
    final db = await database;
    try {
      final columns = await db.rawQuery("PRAGMA table_info(events)");
      if (kDebugMode) {
        print("📊 Structure de la table events:");
        for (var column in columns) {
          print(" - ${column['name']} (${column['type']})");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur lors de la vérification de la structure: $e");
      }
    }
  }

  Future<List<Event>> getAllEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<List<Event>> getUserEvents(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<Event?> getEventById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEvent(Event event, int currentUserId) async {
    if (!event.isOwner(currentUserId)) {
      throw Exception("Unauthorized: You can only update your own events");
    }
    
    final db = await database;
    
    // Créer une map avec les BONS noms de colonnes
    final eventMap = {
      'title': event.title,
      'description': event.description,
      'location': event.location,
      'oddObjectives': event.oddObjectives.join('|'), // CORRIGÉ : oddObjectives
      'date': event.date,
      'image': event.image,
      'category': event.category,
      'price': event.price,
      'updatedAt': event.updatedAt,
      'userId': event.userId,
      'likeCount': event.likeCount,
    };
    
    return await db.update(
      'events',
      eventMap,
      where: 'id = ? AND userId = ?',
      whereArgs: [event.id, currentUserId],
    );
  }

  Future<int> deleteEvent(int id, int currentUserId) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, currentUserId],
    );
  }

  Future<bool> isEventOwner(int eventId, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    return maps.isNotEmpty;
  }

  // EVENT LIKES OPERATIONS
  Future<int> likeEvent(int eventId, int userId) async {
    final db = await database;
    
    // Vérifier si l'utilisateur a déjà liké cet événement
    final existingLike = await db.query(
      'event_likes',
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    
    if (existingLike.isEmpty) {
      // Ajouter le like
      await db.insert('event_likes', {
        'eventId': eventId,
        'userId': userId,
        'createdAt': DateTime.now().toString(),
      });
      
      // Mettre à jour le compteur de likes
      await db.rawUpdate(
        'UPDATE events SET likeCount = likeCount + 1 WHERE id = ?',
        [eventId]
      );
      
      return 1;
    }
    return 0;
  }

  Future<int> unlikeEvent(int eventId, int userId) async {
    final db = await database;
    
    // Supprimer le like
    final result = await db.delete(
      'event_likes',
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
    
    if (result > 0) {
      // Mettre à jour le compteur de likes
      await db.rawUpdate(
        'UPDATE events SET likeCount = likeCount - 1 WHERE id = ?',
        [eventId]
      );
    }
    
    return result;
  }

  Future<bool> isEventLikedByUser(int eventId, int userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'event_likes',
        where: 'eventId = ? AND userId = ?',
        whereArgs: [eventId, userId],
      );
      return result.isNotEmpty;
    } catch (e) {
      // If table doesn't exist, return false
      if (kDebugMode) {
        print("Error checking event like: $e");
      }
      return false;
    }
  }

  Future<List<Event>> getAllEventsWithLikes(int? userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    
    return await Future.wait(maps.map((map) async {
      final event = Event.fromMap(map);
      
      // Vérifier si l'utilisateur courant a liké cet événement
      if (userId != null) {
        final isLiked = await isEventLikedByUser(event.id!, userId);
        return event.copyWith(isLiked: isLiked);
      }
      
      return event;
    }));
  }

  Future<int> getEventLikeCount(int eventId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM event_likes WHERE eventId = ?',
        [eventId]
      );
      return result.first['count'] as int;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting event like count: $e");
      }
      return 0;
    }
  }

  Future<List<Event>> getLikedEvents(int userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT e.* FROM events e
        INNER JOIN event_likes el ON e.id = el.eventId
        WHERE el.userId = ?
        ORDER BY el.createdAt DESC
      ''', [userId]);
      
      return await Future.wait(maps.map((map) async {
        final event = Event.fromMap(map);
        final isLiked = await isEventLikedByUser(event.id!, userId);
        return event.copyWith(isLiked: isLiked);
      }));
    } catch (e) {
      if (kDebugMode) {
        print("Error getting liked events: $e");
      }
      return [];
    }
  }

  // Check if database tables exist (for debugging)
  Future<void> checkDatabaseTables() async {
    final db = await database;
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      if (kDebugMode) {
        print("📊 Database tables:");
        for (var table in tables) {
          print(" - ${table['name']}");
        }
      }
      
      // Check event_likes table specifically
      final eventLikesData = await db.rawQuery(
        "SELECT * FROM event_likes LIMIT 1"
      );
      if (kDebugMode) {
        print("📋 event_likes table exists: ${eventLikesData.isNotEmpty}");
      }

      // Check events table data
      final eventsData = await db.rawQuery("SELECT COUNT(*) as count FROM events");
      if (kDebugMode) {
        print("📋 Events count: ${eventsData.first['count']}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error checking database tables: $e");
      }
    }
  }

  // Password Recovery Operations
  Future<int> insertPasswordRecoveryCode(String email, String code, DateTime expiration) async {
    final db = await database;
    return await db.insert('password_recovery', {
      'email': email,
      'code': code,
      'expiration': expiration.toIso8601String(),
      'used': 0,
    });
  }

  Future<Map<String, dynamic>?> getValidRecoveryCode(String email, String code) async {
    final db = await database;
    final result = await db.query(
      'password_recovery',
      where: 'email = ? AND code = ? AND used = 0 AND expiration > ?',
      whereArgs: [email, code, DateTime.now().toIso8601String()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> markRecoveryCodeAsUsed(String email, String code) async {
    final db = await database;
    return await db.update(
      'password_recovery',
      {'used': 1},
      where: 'email = ? AND code = ?',
      whereArgs: [email, code],
    );
  }

  Future<void> cleanupExpiredRecoveryCodes() async {
    final db = await database;
    await db.delete(
      'password_recovery',
      where: 'expiration < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  /**************************************************** */
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
  /*Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ridesharing.db');
    await deleteDatabase(path);
    _database = null;
    await database; // Réinitialiser
  }*/

}
*/