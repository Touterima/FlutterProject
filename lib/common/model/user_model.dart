import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phoneNumber;

  @HiveField(4)
  String gender;

  @HiveField(5)
  String password;

  @HiveField(6)
  String? avatarInitials;

  @HiveField(7)
  String? registrationIp;

  @HiveField(8)
  String? registrationCountry;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.password,
    this.avatarInitials,
    this.registrationIp,
    this.registrationCountry,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'password': password,
      'avatarInitials': avatarInitials,
      'registrationIp': registrationIp,
      'registrationCountry': registrationCountry,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      password: map['password'],
      avatarInitials: map['avatarInitials'],
      registrationIp: map['registrationIp'],
      registrationCountry: map['registrationCountry'],
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, gender: $gender, avatarInitials: $avatarInitials, registrationIp: $registrationIp, registrationCountry: $registrationCountry}';
  }
}