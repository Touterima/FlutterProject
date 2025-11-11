import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/user_model.dart';
import '../model/event_model.dart';
import '../model/event_like_model.dart';
import '../model/password_recovery_model.dart';
import '../model/trajet_model.dart';
import '../model/reservation_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Box names
  static const String usersBox = 'users';
  static const String eventsBox = 'events';
  static const String eventLikesBox = 'event_likes';
  static const String passwordRecoveryBox = 'password_recovery';
  static const String trajetsBox = 'trajets';
  static const String reservationsBox = 'reservations';

  bool _initialized = false;

  /// Initialize Hive database
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(EventAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(EventLikeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PasswordRecoveryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TrajetAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ReservationAdapter());
    }

    // Open boxes
    await Hive.openBox<User>(usersBox);
    await Hive.openBox<Event>(eventsBox);
    await Hive.openBox<EventLike>(eventLikesBox);
    await Hive.openBox<PasswordRecovery>(passwordRecoveryBox);
    await Hive.openBox<Trajet>(trajetsBox);
    await Hive.openBox<Reservation>(reservationsBox);

    // Insert static data if needed
    await _insertStaticDataIfNeeded();

    _initialized = true;

    if (kDebugMode) {
      print("✅ Hive database initialized");
    }
  }

  /// Insert static data for testing
  Future<void> _insertStaticDataIfNeeded() async {
    final trajetsBoxInstance = Hive.box<Trajet>(trajetsBox);
    
    if (trajetsBoxInstance.isEmpty) {
      await insertTrajet(Trajet(
        conducteur: 'Rima Toute',
        pointDepart: 'Tunis',
        pointArrivee: 'Sousse',
        date: '2025-11-15',
        heure: '08:00',
        nbPlaces: 4,
        nbPlacesDispo: 4,
        prix: 15.0,
        description: 'Trajet direct, départ ponctuel',
      ));

      await insertTrajet(Trajet(
        conducteur: 'Fairouz Felfel',
        pointDepart: 'Sfax',
        pointArrivee: 'Tunis',
        date: '2025-11-16',
        heure: '14:30',
        nbPlaces: 3,
        nbPlacesDispo: 2,
        prix: 20.0,
        description: 'Climatisation, musique agréable',
      ));

      await insertTrajet(Trajet(
        conducteur: 'Melek bns',
        pointDepart: 'Bizerte',
        pointArrivee: 'Nabeul',
        date: '2025-11-17',
        heure: '10:00',
        nbPlaces: 4,
        nbPlacesDispo: 3,
        prix: 12.0,
        description: 'Arrêt possible à mi-chemin',
      ));
    }
  }

  // ==================== USER OPERATIONS ====================

  Future<int> insertUser(User user) async {
    try {
      final box = Hive.box<User>(usersBox);
      final normalizedEmail = _normalizeEmail(user.email);
      
      // Check if email already exists
      if (await isEmailExists(user.email)) {
        throw Exception("Email already exists");
      }

      // Generate ID
      final id = box.isEmpty ? 1 : box.values.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      
      final normalizedUser = User(
        id: id,
        name: user.name,
        email: normalizedEmail,
        phoneNumber: user.phoneNumber,
        gender: user.gender,
        password: user.password,
        avatarInitials: user.avatarInitials,
        registrationIp: user.registrationIp,
        registrationCountry: user.registrationCountry,
      );

      await box.put(id, normalizedUser);

      if (kDebugMode) {
        print("✅ Utilisateur inséré: ${normalizedUser.email} (ID: $id)");
        print("🎨 Initiales: ${normalizedUser.avatarInitials}");
        print("🌍 Pays: ${normalizedUser.registrationCountry}");
      }

      return id;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur insertion: $e");
      }
      rethrow;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final box = Hive.box<User>(usersBox);
    final normalizedEmail = _normalizeEmail(email);
    
    try {
      return box.values.firstWhere(
        (user) => _normalizeEmail(user.email) == normalizedEmail,
      );
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserById(int id) async {
    final box = Hive.box<User>(usersBox);
    return box.get(id);
  }

  Future<List<User>> getAllUsers() async {
    final box = Hive.box<User>(usersBox);
    return box.values.toList();
  }

  Future<int> updateUser(User user) async {
    final box = Hive.box<User>(usersBox);
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

    await box.put(user.id!, normalizedUser);
    return 1;
  }

  Future<int> deleteUser(int id) async {
    final box = Hive.box<User>(usersBox);
    await box.delete(id);
    return 1;
  }

  Future<bool> checkUserCredentials(String email, String password) async {
    final user = await getUserByEmail(email);
    return user != null && user.password == password;
  }

  Future<bool> isEmailExists(String email) async {
    final box = Hive.box<User>(usersBox);
    final normalizedEmail = _normalizeEmail(email);
    
    final exists = box.values.any(
      (user) => _normalizeEmail(user.email) == normalizedEmail,
    );

    return exists;
  }

  String _normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  Future<void> fixDuplicateEmails() async {
    final box = Hive.box<User>(usersBox);
    final seenEmails = <String>{};
    final toDelete = <int>[];

    for (var user in box.values) {
      final normalizedEmail = _normalizeEmail(user.email);
      if (seenEmails.contains(normalizedEmail)) {
        toDelete.add(user.id!);
      } else {
        seenEmails.add(normalizedEmail);
      }
    }

    for (var id in toDelete) {
      await box.delete(id);
    }

    if (kDebugMode) {
      print("🧹 ${toDelete.length} doublons supprimés");
    }
  }

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

  // ==================== EVENT OPERATIONS ====================

  Future<int> insertEvent(Event event) async {
    try {
      final box = Hive.box<Event>(eventsBox);
      
      // Generate ID
      final id = box.isEmpty ? 1 : box.values.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      
      final newEvent = Event(
        id: id,
        title: event.title,
        description: event.description,
        location: event.location,
        oddObjectives: event.oddObjectives,
        date: event.date,
        image: event.image,
        category: event.category,
        price: event.price,
        creationAt: event.creationAt ?? DateTime.now().toIso8601String(),
        updatedAt: event.updatedAt ?? DateTime.now().toIso8601String(),
        userId: event.userId,
        likeCount: event.likeCount,
      );

      await box.put(id, newEvent);

      if (kDebugMode) {
        print("✅ Event inserted: ${event.title} (ID: $id, User: ${event.userId})");
        print("📋 SDGs: ${event.oddObjectives.join(', ')}");
      }

      return id;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error inserting event: $e");
      }
      rethrow;
    }
  }

  Future<List<Event>> getAllEvents() async {
    final box = Hive.box<Event>(eventsBox);
    return box.values.toList();
  }

  Future<List<Event>> getUserEvents(int userId) async {
    final box = Hive.box<Event>(eventsBox);
    return box.values.where((event) => event.userId == userId).toList();
  }

  Future<Event?> getEventById(int id) async {
    final box = Hive.box<Event>(eventsBox);
    return box.get(id);
  }

  Future<int> updateEvent(Event event, int currentUserId) async {
    if (!event.isOwner(currentUserId)) {
      throw Exception("Unauthorized: You can only update your own events");
    }

    final box = Hive.box<Event>(eventsBox);
    
    final updatedEvent = event.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );

    await box.put(event.id!, updatedEvent);
    return 1;
  }

  Future<int> deleteEvent(int id, int currentUserId) async {
    final box = Hive.box<Event>(eventsBox);
    final event = box.get(id);
    
    if (event == null || event.userId != currentUserId) {
      return 0;
    }

    await box.delete(id);
    
    // Delete associated likes
    final likesBox = Hive.box<EventLike>(eventLikesBox);
    final likesToDelete = likesBox.values
        .where((like) => like.eventId == id)
        .map((like) => like.key)
        .toList();
    
    for (var key in likesToDelete) {
      await likesBox.delete(key);
    }

    return 1;
  }

  Future<bool> isEventOwner(int eventId, int userId) async {
    final box = Hive.box<Event>(eventsBox);
    final event = box.get(eventId);
    return event != null && event.userId == userId;
  }

  // ==================== EVENT LIKES OPERATIONS ====================

  Future<int> likeEvent(int eventId, int userId) async {
    final likesBox = Hive.box<EventLike>(eventLikesBox);
    
    // Check if already liked
    final existingLike = likesBox.values.any(
      (like) => like.eventId == eventId && like.userId == userId,
    );

    if (!existingLike) {
      final like = EventLike(
        eventId: eventId,
        userId: userId,
        createdAt: DateTime.now().toIso8601String(),
      );
      
      await likesBox.add(like);

      // Update event like count
      final eventBox = Hive.box<Event>(eventsBox);
      final event = eventBox.get(eventId);
      if (event != null) {
        await eventBox.put(
          eventId,
          event.copyWith(likeCount: event.likeCount + 1),
        );
      }

      return 1;
    }
    return 0;
  }

  Future<int> unlikeEvent(int eventId, int userId) async {
    final likesBox = Hive.box<EventLike>(eventLikesBox);
    
    // Find and delete the like
    final likeKey = likesBox.keys.firstWhere(
      (key) {
        final like = likesBox.get(key);
        return like != null && like.eventId == eventId && like.userId == userId;
      },
      orElse: () => null,
    );

    if (likeKey != null) {
      await likesBox.delete(likeKey);

      // Update event like count
      final eventBox = Hive.box<Event>(eventsBox);
      final event = eventBox.get(eventId);
      if (event != null) {
        await eventBox.put(
          eventId,
          event.copyWith(likeCount: event.likeCount - 1),
        );
      }

      return 1;
    }
    return 0;
  }

  Future<bool> isEventLikedByUser(int eventId, int userId) async {
    try {
      final likesBox = Hive.box<EventLike>(eventLikesBox);
      return likesBox.values.any(
        (like) => like.eventId == eventId && like.userId == userId,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error checking event like: $e");
      }
      return false;
    }
  }

  Future<List<Event>> getAllEventsWithLikes(int? userId) async {
    final events = await getAllEvents();
    
    if (userId == null) return events;

    return await Future.wait(
      events.map((event) async {
        final isLiked = await isEventLikedByUser(event.id!, userId);
        return event.copyWith(isLiked: isLiked);
      }),
    );
  }

  Future<int> getEventLikeCount(int eventId) async {
    try {
      final likesBox = Hive.box<EventLike>(eventLikesBox);
      return likesBox.values.where((like) => like.eventId == eventId).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting event like count: $e");
      }
      return 0;
    }
  }

  Future<List<Event>> getLikedEvents(int userId) async {
    try {
      final likesBox = Hive.box<EventLike>(eventLikesBox);
      final eventBox = Hive.box<Event>(eventsBox);
      
      final likedEventIds = likesBox.values
          .where((like) => like.userId == userId)
          .map((like) => like.eventId)
          .toSet();

      return await Future.wait(
        likedEventIds.map((eventId) async {
          final event = eventBox.get(eventId);
          if (event != null) {
            return event.copyWith(isLiked: true);
          }
          return null;
        }),
      ).then((events) => events.whereType<Event>().toList());
    } catch (e) {
      if (kDebugMode) {
        print("Error getting liked events: $e");
      }
      return [];
    }
  }

  // ==================== PASSWORD RECOVERY OPERATIONS ====================

  Future<int> insertPasswordRecoveryCode(
    String email,
    String code,
    DateTime expiration,
  ) async {
    final box = Hive.box<PasswordRecovery>(passwordRecoveryBox);
    
    final recovery = PasswordRecovery(
      email: email,
      code: code,
      expiration: expiration.toIso8601String(),
      used: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    await box.add(recovery);
    return 1;
  }

  Future<Map<String, dynamic>?> getValidRecoveryCode(
    String email,
    String code,
  ) async {
    final box = Hive.box<PasswordRecovery>(passwordRecoveryBox);
    
    try {
      final recovery = box.values.firstWhere(
        (r) =>
            r.email == email &&
            r.code == code &&
            !r.used &&
            DateTime.parse(r.expiration).isAfter(DateTime.now()),
      );

      return {
        'email': recovery.email,
        'code': recovery.code,
        'expiration': recovery.expiration,
        'used': recovery.used ? 1 : 0,
      };
    } catch (e) {
      return null;
    }
  }

  Future<int> markRecoveryCodeAsUsed(String email, String code) async {
    final box = Hive.box<PasswordRecovery>(passwordRecoveryBox);
    
    final key = box.keys.firstWhere(
      (key) {
        final recovery = box.get(key);
        return recovery != null && recovery.email == email && recovery.code == code;
      },
      orElse: () => null,
    );

    if (key != null) {
      final recovery = box.get(key)!;
      await box.put(
        key,
        PasswordRecovery(
          email: recovery.email,
          code: recovery.code,
          expiration: recovery.expiration,
          used: true,
          createdAt: recovery.createdAt,
        ),
      );
      return 1;
    }
    return 0;
  }

  Future<void> cleanupExpiredRecoveryCodes() async {
    final box = Hive.box<PasswordRecovery>(passwordRecoveryBox);
    final now = DateTime.now();
    
    final expiredKeys = box.keys.where((key) {
      final recovery = box.get(key);
      return recovery != null && DateTime.parse(recovery.expiration).isBefore(now);
    }).toList();

    for (var key in expiredKeys) {
      await box.delete(key);
    }
  }

  // ==================== TRAJET OPERATIONS ====================

  Future<int> insertTrajet(Trajet trajet) async {
    try {
      final box = Hive.box<Trajet>(trajetsBox);
      
      // Generate ID
      final id = box.isEmpty ? 1 : box.values.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      
      final newTrajet = Trajet(
        id: id,
        conducteur: trajet.conducteur,
        pointDepart: trajet.pointDepart,
        pointArrivee: trajet.pointArrivee,
        date: trajet.date,
        heure: trajet.heure,
        nbPlaces: trajet.nbPlaces,
        nbPlacesDispo: trajet.nbPlacesDispo,
        prix: trajet.prix,
        description: trajet.description,
        conducteurId: trajet.conducteurId,
      );

      await box.put(id, newTrajet);

      if (kDebugMode) {
        print("✅ Trajet inséré: ${trajet.pointDepart} → ${trajet.pointArrivee} (ID: $id)");
      }

      return id;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur insertion trajet: $e");
      }
      rethrow;
    }
  }

  Future<List<Trajet>> getAllTrajets() async {
    final box = Hive.box<Trajet>(trajetsBox);
    return box.values.toList();
  }

  Future<Trajet?> getTrajetById(int id) async {
    final box = Hive.box<Trajet>(trajetsBox);
    return box.get(id);
  }

  Future<List<Trajet>> getTrajetsByConducteur(int conducteurId) async {
    final box = Hive.box<Trajet>(trajetsBox);
    return box.values.where((trajet) => trajet.conducteurId == conducteurId).toList();
  }

  Future<int> updateTrajet(Trajet trajet) async {
    final box = Hive.box<Trajet>(trajetsBox);
    await box.put(trajet.id!, trajet);
    return 1;
  }

  Future<int> deleteTrajet(int id) async {
    final box = Hive.box<Trajet>(trajetsBox);
    await box.delete(id);
    
    // Delete associated reservations
    final resBox = Hive.box<Reservation>(reservationsBox);
    final reservationsToDelete = resBox.values
        .where((reservation) => reservation.trajetId == id)
        .map((reservation) => reservation.key)
        .toList();
    
    for (var key in reservationsToDelete) {
      await resBox.delete(key);
    }
    
    return 1;
  }

  Future<void> updatePlacesDispo(int trajetId, int nbPlacesReservees) async {
    final trajet = await getTrajetById(trajetId);
    if (trajet != null) {
      final updatedTrajet = trajet.copyWith(
        nbPlacesDispo: trajet.nbPlacesDispo - nbPlacesReservees,
      );
      await updateTrajet(updatedTrajet);
    }
  }

  Future<List<Trajet>> searchTrajets({
    String? pointDepart,
    String? pointArrivee,
    String? date,
  }) async {
    final allTrajets = await getAllTrajets();
    
    return allTrajets.where((trajet) {
      bool matches = true;
      
      if (pointDepart != null && pointDepart.isNotEmpty) {
        matches = matches && trajet.pointDepart.toLowerCase().contains(pointDepart.toLowerCase());
      }
      
      if (pointArrivee != null && pointArrivee.isNotEmpty) {
        matches = matches && trajet.pointArrivee.toLowerCase().contains(pointArrivee.toLowerCase());
      }
      
      if (date != null && date.isNotEmpty) {
        matches = matches && trajet.date == date;
      }
      
      return matches;
    }).toList();
  }

  // ==================== RESERVATION OPERATIONS ====================

  Future<int> insertReservation(Reservation reservation) async {
    try {
      final box = Hive.box<Reservation>(reservationsBox);
      
      // Generate ID
      final id = box.isEmpty ? 1 : box.values.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      
      final newReservation = Reservation(
        id: id,
        userId: reservation.userId,
        trajetId: reservation.trajetId,
        nbPlacesReservees: reservation.nbPlacesReservees,
        dateReservation: reservation.dateReservation,
        statut: reservation.statut,
        prixTotal: reservation.prixTotal,
      );

      await box.put(id, newReservation);

      // Update available places
      await updatePlacesDispo(reservation.trajetId, reservation.nbPlacesReservees);

      if (kDebugMode) {
        print("✅ Réservation insérée: User ${reservation.userId}, Trajet ${reservation.trajetId} (ID: $id)");
      }

      return id;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur insertion réservation: $e");
      }
      rethrow;
    }
  }

  Future<List<Reservation>> getAllReservations() async {
    final box = Hive.box<Reservation>(reservationsBox);
    return box.values.toList();
  }

  Future<Reservation?> getReservationById(int id) async {
    final box = Hive.box<Reservation>(reservationsBox);
    return box.get(id);
  }

  Future<List<Reservation>> getReservationsByUserId(int userId) async {
    final box = Hive.box<Reservation>(reservationsBox);
    return box.values.where((reservation) => reservation.userId == userId).toList();
  }

  Future<List<Reservation>> getReservationsByTrajetId(int trajetId) async {
    final box = Hive.box<Reservation>(reservationsBox);
    return box.values.where((reservation) => reservation.trajetId == trajetId).toList();
  }

  Future<int> updateReservation(Reservation reservation) async {
    final box = Hive.box<Reservation>(reservationsBox);
    await box.put(reservation.id!, reservation);
    return 1;
  }

  Future<int> deleteReservation(int id) async {
    final box = Hive.box<Reservation>(reservationsBox);
    final reservation = box.get(id);
    
    if (reservation != null) {
      // Restore available places
      final trajet = await getTrajetById(reservation.trajetId);
      if (trajet != null) {
        final updatedTrajet = trajet.copyWith(
          nbPlacesDispo: trajet.nbPlacesDispo + reservation.nbPlacesReservees,
        );
        await updateTrajet(updatedTrajet);
      }
      
      await box.delete(id);
      return 1;
    }
    
    return 0;
  }

  Future<int> cancelReservation(int id) async {
    final reservation = await getReservationById(id);
    
    if (reservation != null) {
      final updatedReservation = reservation.copyWith(statut: 'annulee');
      await updateReservation(updatedReservation);
      
      // Restore available places
      final trajet = await getTrajetById(reservation.trajetId);
      if (trajet != null) {
        final updatedTrajet = trajet.copyWith(
          nbPlacesDispo: trajet.nbPlacesDispo + reservation.nbPlacesReservees,
        );
        await updateTrajet(updatedTrajet);
      }
      
      return 1;
    }
    
    return 0;
  }

  // ==================== UTILITY METHODS ====================

  Future<void> resetDatabase() async {
    await Hive.box<User>(usersBox).clear();
    await Hive.box<Event>(eventsBox).clear();
    await Hive.box<EventLike>(eventLikesBox).clear();
    await Hive.box<PasswordRecovery>(passwordRecoveryBox).clear();
    await Hive.box<Trajet>(trajetsBox).clear();
    await Hive.box<Reservation>(reservationsBox).clear();
    
    if (kDebugMode) {
      print("🗑️ Base de données complètement réinitialisée");
    }
  }

  Future<void> completeResetDatabase() async {
    await resetDatabase();
  }

  Future<void> checkDatabaseTables() async {
    if (kDebugMode) {
      print("📊 Database boxes:");
      print(" - $usersBox: ${Hive.box<User>(usersBox).length} items");
      print(" - $eventsBox: ${Hive.box<Event>(eventsBox).length} items");
      print(" - $eventLikesBox: ${Hive.box<EventLike>(eventLikesBox).length} items");
      print(" - $passwordRecoveryBox: ${Hive.box<PasswordRecovery>(passwordRecoveryBox).length} items");
      print(" - $trajetsBox: ${Hive.box<Trajet>(trajetsBox).length} items");
      print(" - $reservationsBox: ${Hive.box<Reservation>(reservationsBox).length} items");
    }
  }
}