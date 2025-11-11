class User {
  int? id;
  String name;
  String email;
  String phoneNumber;
  String gender;
  String password;
  String? avatarInitials;
  String? registrationIp;
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