import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../model/user_model.dart';

class PasswordRecoveryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Générer un code de récupération
  String _generateRecoveryCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 1000000).toString().padLeft(6, '0');
  }

  // Vérifier si l'email existe
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _databaseHelper.isEmailExists(email);
    } catch (e) {
      debugPrint("❌ Erreur vérification email: $e");
      return false;
    }
  }

  // Envoyer le code de récupération par email (simulation)
  Future<Map<String, dynamic>> sendRecoveryCode(String email) async {
    try {
      // Vérifier d'abord si l'email existe
      final emailExists = await checkEmailExists(email);
      if (!emailExists) {
        return {
          'success': false,
          'message': 'Aucun compte trouvé avec cet email',
        };
      }

      // Générer le code de récupération
      final recoveryCode = _generateRecoveryCode();
      final expirationTime = DateTime.now().add(const Duration(minutes: 15));

      // Enregistrer le code dans la base de données
      await _storeRecoveryCode(email, recoveryCode, expirationTime);

      // SIMULATION: Envoi d'email
      debugPrint("=== 📧 EMAIL DE RÉCUPÉRATION ===");
      debugPrint("Destinataire: $email");
      debugPrint("Code de récupération: $recoveryCode");
      debugPrint("Expire à: $expirationTime");
      debugPrint("=== FIN SIMULATION EMAIL ===");

      return {
        'success': true,
        'message': 'Code de récupération envoyé à votre email',
        'code': recoveryCode, // Pour le debug
        'expiration': expirationTime.toIso8601String(),
      };
    } catch (e) {
      debugPrint("❌ Erreur envoi code récupération: $e");
      return {
        'success': false,
        'message': 'Erreur lors de l\'envoi du code',
      };
    }
  }

  // Stocker le code de récupération dans la base de données
  Future<void> _storeRecoveryCode(String email, String code, DateTime expiration) async {
    try {
      final db = await _databaseHelper.database;
      
      // Créer la table si elle n'existe pas
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

      // Désactiver les anciens codes pour cet email
      await db.update(
        'password_recovery',
        {'used': 1},
        where: 'email = ? AND used = 0',
        whereArgs: [email],
      );

      // Insérer le nouveau code
      await db.insert('password_recovery', {
        'email': email,
        'code': code,
        'expiration': expiration.toIso8601String(),
        'used': 0,
      });

      debugPrint("✅ Code de récupération stocké pour: $email");
    } catch (e) {
      debugPrint("❌ Erreur stockage code récupération: $e");
      rethrow;
    }
  }

  // Vérifier le code de récupération
  Future<Map<String, dynamic>> verifyRecoveryCode(String email, String code) async {
    try {
      final db = await _databaseHelper.database;
      
      final result = await db.query(
        'password_recovery',
        where: 'email = ? AND code = ? AND used = 0',
        whereArgs: [email, code],
      );

      if (result.isEmpty) {
        return {
          'success': false,
          'message': 'Code invalide ou expiré',
        };
      }

      final recoveryData = result.first;
      final expiration = DateTime.parse(recoveryData['expiration'] as String);

      if (expiration.isBefore(DateTime.now())) {
        return {
          'success': false,
          'message': 'Code expiré',
        };
      }

      return {
        'success': true,
        'message': 'Code vérifié avec succès',
        'recoveryId': recoveryData['id'],
      };
    } catch (e) {
      debugPrint("❌ Erreur vérification code: $e");
      return {
        'success': false,
        'message': 'Erreur lors de la vérification',
      };
    }
  }

  // Réinitialiser le mot de passe
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword, int recoveryId) async {
    try {
      final db = await _databaseHelper.database;
      
      // Marquer le code comme utilisé
      await db.update(
        'password_recovery',
        {'used': 1},
        where: 'id = ?',
        whereArgs: [recoveryId],
      );

      // Mettre à jour le mot de passe utilisateur
      final user = await _databaseHelper.getUserByEmail(email);
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé',
        };
      }

      final updatedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        gender: user.gender,
        password: newPassword,
        avatarInitials: user.avatarInitials,
        registrationIp: user.registrationIp,
        registrationCountry: user.registrationCountry,
      );

      await _databaseHelper.updateUser(updatedUser);

      debugPrint("✅ Mot de passe réinitialisé pour: $email");

      return {
        'success': true,
        'message': 'Mot de passe réinitialisé avec succès',
      };
    } catch (e) {
      debugPrint("❌ Erreur réinitialisation mot de passe: $e");
      return {
        'success': false,
        'message': 'Erreur lors de la réinitialisation',
      };
    }
  }

  // Nettoyer les codes expirés
  Future<void> cleanupExpiredCodes() async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now().toIso8601String();
      
      await db.delete(
        'password_recovery',
        where: 'expiration < ? AND used = 0',
        whereArgs: [now],
      );

      debugPrint("🧹 Codes de récupération expirés nettoyés");
    } catch (e) {
      debugPrint("❌ Erreur nettoyage codes: $e");
    }
  }
}