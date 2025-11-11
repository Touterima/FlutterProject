import 'package:hive/hive.dart';

part 'reservation_model.g.dart';

@HiveType(typeId: 5)
class Reservation extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  int trajetId;

  @HiveField(3)
  int nbPlacesReservees;

  @HiveField(4)
  String dateReservation;

  @HiveField(5)
  String? statut; // 'confirmee', 'annulee', 'en_attente'

  @HiveField(6)
  double? prixTotal;

  Reservation({
    this.id,
    required this.userId,
    required this.trajetId,
    required this.nbPlacesReservees,
    required this.dateReservation,
    this.statut = 'confirmee',
    this.prixTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'trajet_id': trajetId,
      'nb_places_reservees': nbPlacesReservees,
      'date_reservation': dateReservation,
      'statut': statut,
      'prix_total': prixTotal,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      userId: map['user_id'] ?? 0,
      trajetId: map['trajet_id'] ?? 0,
      nbPlacesReservees: map['nb_places_reservees'] ?? 1,
      dateReservation: map['date_reservation'] ?? DateTime.now().toIso8601String(),
      statut: map['statut'] ?? 'confirmee',
      prixTotal: map['prix_total']?.toDouble(),
    );
  }

  Reservation copyWith({
    int? id,
    int? userId,
    int? trajetId,
    int? nbPlacesReservees,
    String? dateReservation,
    String? statut,
    double? prixTotal,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trajetId: trajetId ?? this.trajetId,
      nbPlacesReservees: nbPlacesReservees ?? this.nbPlacesReservees,
      dateReservation: dateReservation ?? this.dateReservation,
      statut: statut ?? this.statut,
      prixTotal: prixTotal ?? this.prixTotal,
    );
  }
}