import 'package:hive/hive.dart';

part 'trajet_model.g.dart';

@HiveType(typeId: 4)
class Trajet extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String conducteur;

  @HiveField(2)
  String pointDepart;

  @HiveField(3)
  String pointArrivee;

  @HiveField(4)
  String date;

  @HiveField(5)
  String heure;

  @HiveField(6)
  int nbPlaces;

  @HiveField(7)
  int nbPlacesDispo;

  @HiveField(8)
  double prix;

  @HiveField(9)
  String? description;

  @HiveField(10)
  int? conducteurId; // Link to User ID

  Trajet({
    this.id,
    required this.conducteur,
    required this.pointDepart,
    required this.pointArrivee,
    required this.date,
    required this.heure,
    required this.nbPlaces,
    required this.nbPlacesDispo,
    required this.prix,
    this.description,
    this.conducteurId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conducteur': conducteur,
      'point_depart': pointDepart,
      'point_arrivee': pointArrivee,
      'date': date,
      'heure': heure,
      'nb_places': nbPlaces,
      'nb_places_dispo': nbPlacesDispo,
      'prix': prix,
      'description': description,
      'conducteur_id': conducteurId,
    };
  }

  factory Trajet.fromMap(Map<String, dynamic> map) {
    return Trajet(
      id: map['id'],
      conducteur: map['conducteur'] ?? '',
      pointDepart: map['point_depart'] ?? '',
      pointArrivee: map['point_arrivee'] ?? '',
      date: map['date'] ?? '',
      heure: map['heure'] ?? '',
      nbPlaces: map['nb_places'] ?? 0,
      nbPlacesDispo: map['nb_places_dispo'] ?? 0,
      prix: (map['prix'] ?? 0.0).toDouble(),
      description: map['description'],
      conducteurId: map['conducteur_id'],
    );
  }

  Trajet copyWith({
    int? id,
    String? conducteur,
    String? pointDepart,
    String? pointArrivee,
    String? date,
    String? heure,
    int? nbPlaces,
    int? nbPlacesDispo,
    double? prix,
    String? description,
    int? conducteurId,
  }) {
    return Trajet(
      id: id ?? this.id,
      conducteur: conducteur ?? this.conducteur,
      pointDepart: pointDepart ?? this.pointDepart,
      pointArrivee: pointArrivee ?? this.pointArrivee,
      date: date ?? this.date,
      heure: heure ?? this.heure,
      nbPlaces: nbPlaces ?? this.nbPlaces,
      nbPlacesDispo: nbPlacesDispo ?? this.nbPlacesDispo,
      prix: prix ?? this.prix,
      description: description ?? this.description,
      conducteurId: conducteurId ?? this.conducteurId,
    );
  }
}