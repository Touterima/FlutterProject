//lib/common/model/trip_model.dart
class TripModel {
  String id;
  String from;
  String to;
  String driverName;
  String driverPhone;
  DateTime departureTime;
  int availableSeats;
  int totalSeats;
  double pricePerSeat;
  String vehicleType;
  List<String> bookedBy; // Liste des IDs des utilisateurs qui ont réservé

  TripModel({
    required this.id,
    required this.from,
    required this.to,
    required this.driverName,
    required this.driverPhone,
    required this.departureTime,
    required this.availableSeats,
    required this.totalSeats,
    required this.pricePerSeat,
    required this.vehicleType,
    this.bookedBy = const [],
  });

  // Convertir en JSON pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'departureTime': departureTime.toIso8601String(),
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'pricePerSeat': pricePerSeat,
      'vehicleType': vehicleType,
      'bookedBy': bookedBy,
    };
  }

  // Créer depuis JSON
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      departureTime: DateTime.parse(json['departureTime']),
      availableSeats: json['availableSeats'],
      totalSeats: json['totalSeats'],
      pricePerSeat: json['pricePerSeat'],
      vehicleType: json['vehicleType'],
      bookedBy: List<String>.from(json['bookedBy'] ?? []),
    );
  }

  // Copier avec modifications
  TripModel copyWith({
    String? id,
    String? from,
    String? to,
    String? driverName,
    String? driverPhone,
    DateTime? departureTime,
    int? availableSeats,
    int? totalSeats,
    double? pricePerSeat,
    String? vehicleType,
    List<String>? bookedBy,
  }) {
    return TripModel(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      vehicleType: vehicleType ?? this.vehicleType,
      bookedBy: bookedBy ?? this.bookedBy,
    );
  }
}