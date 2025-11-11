import 'package:hive/hive.dart';

part 'password_recovery_model.g.dart';

@HiveType(typeId: 3)
class PasswordRecovery extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String code;

  @HiveField(2)
  final String expiration;

  @HiveField(3)
  final bool used;

  @HiveField(4)
  final String createdAt;

  PasswordRecovery({
    required this.email,
    required this.code,
    required this.expiration,
    required this.used,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'code': code,
      'expiration': expiration,
      'used': used ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory PasswordRecovery.fromMap(Map<String, dynamic> map) {
    return PasswordRecovery(
      email: map['email'],
      code: map['code'],
      expiration: map['expiration'],
      used: map['used'] == 1,
      createdAt: map['createdAt'],
    );
  }

  @override
  String toString() {
    return 'PasswordRecovery{email: $email, code: $code, expiration: $expiration, used: $used, createdAt: $createdAt}';
  }
}