import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../model/user_model.dart';
import 'abstract_api_service.dart';
import 'password_recovery_service.dart';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AbstractApiService _apiService = AbstractApiService();
  final PasswordRecoveryService _passwordRecoveryService = PasswordRecoveryService();

  static int? currentUserId;

  Future<bool> register(User user) async {
    try {
      final normalizedEmail = _normalizeEmail(user.email);
      
      bool emailExists = await _databaseHelper.isEmailExists(normalizedEmail);
      if (emailExists) {
        debugPrint("🚫 Email déjà existant: $normalizedEmail");
        return false;
      }

      // 1. VALIDATION EMAIL - VERSION CORRIGÉE
      debugPrint("🔍 Validation de l'email avec Abstract API...");
      final emailValidation = await _apiService.validateEmail(normalizedEmail);

      // LOG DÉTAILLÉ ET SÉCURISÉ
      debugPrint("=== 📧 RAPPORT VALIDATION EMAIL ===");
      debugPrint("Email: $normalizedEmail");
      debugPrint("Valide: ${emailValidation['isValid']}");
      debugPrint("Format valide: ${emailValidation['isFormatValid']}");
      debugPrint("Délivrable: ${emailValidation['isDeliverable']}");
      debugPrint("Jetable: ${emailValidation['isDisposable']}");
      debugPrint("SMTP valide: ${emailValidation['isSmtpValid']}");
      debugPrint("Status: ${emailValidation['deliverabilityStatus']}");
      debugPrint("Score qualité: ${emailValidation['qualityScore']}");
      debugPrint("=== FIN RAPPORT ===");

      // CRITÈRES DE VALIDATION SÉCURISÉS
      if (emailValidation['isValid'] != true) {
        debugPrint("❌ Email invalide");
        return false;
      }

      if (emailValidation['isDisposable'] == true) {
        debugPrint("❌ Email jetable détecté");
        return false;
      }

      // 2. VALIDATION TÉLÉPHONE
      debugPrint("🔍 Validation du téléphone avec Abstract API...");
      final phoneValidation = await _apiService.validatePhone(user.phoneNumber, "TN");

      debugPrint("=== 📱 RAPPORT VALIDATION TÉLÉPHONE ===");
      debugPrint("Numéro: ${user.phoneNumber}");
      debugPrint("Valide: ${phoneValidation['isValid']}");
      debugPrint("Actif: ${phoneValidation['isActive']}");
      debugPrint("Mobile: ${phoneValidation['isMobile']}");
      debugPrint("Non-VoIP: ${phoneValidation['isNotVoip']}");
      debugPrint("Non-jetable: ${phoneValidation['isNotDisposable']}");
      debugPrint("Type: ${phoneValidation['type']}");
      debugPrint("Opérateur: ${phoneValidation['carrier']}");
      debugPrint("Pays: ${phoneValidation['country']}");
      debugPrint("=== FIN RAPPORT ===");

      if (phoneValidation['isValid'] != true) {
        debugPrint("❌ Numéro de téléphone invalide");
        return false;
      }

      if (phoneValidation['isActive'] != true) {
        debugPrint("❌ Ligne téléphonique inactive");
        return false;
      }

      if (phoneValidation['isNotVoip'] != true) {
        debugPrint("❌ Ligne VoIP détectée");
        return false;
      }

      if (phoneValidation['isNotDisposable'] != true) {
        debugPrint("❌ Numéro jetable détecté");
        return false;
      }

      debugPrint("✅ Téléphone validé avec succès");

      // 3. GÉNÉRATION INITIALES AVATAR
      debugPrint("🎨 Génération des initiales d'avatar...");
      final avatarInitials = await _apiService.generateAvatarInitials(user.name);

      // 4. GÉOLOCALISATION IP
      debugPrint("🌍 Récupération des informations de sécurité...");
      final userIp = await _apiService.getUserIp();
      final ipGeolocation = await _apiService.getIpGeolocation(userIp);
      final ipIntelligence = await _apiService.getIpIntelligence(userIp);

      if (ipIntelligence['isProxy'] == true || ipIntelligence['isVpn'] == true) {
        debugPrint("⚠️  Inscription suspecte détectée (Proxy/VPN)");
        debugPrint("🛡️  Score de risque: ${ipIntelligence['riskScore']}");
      }

      // Création utilisateur
      User normalizedUser = User(
        name: user.name,
        email: normalizedEmail,
        phoneNumber: user.phoneNumber,
        gender: user.gender,
        password: user.password,
        avatarInitials: avatarInitials,
        registrationIp: userIp,
        registrationCountry: ipGeolocation['country'],
      );
      
      await _databaseHelper.insertUser(normalizedUser);
      debugPrint("✅ Nouvel utilisateur créé avec validation API: $normalizedEmail");
      debugPrint("🎨 Initiales: $avatarInitials");
      debugPrint("🌍 Pays: ${ipGeolocation['country']}");
      debugPrint("🛡️ Sécurité: Proxy=${ipIntelligence['isProxy']}, VPN=${ipIntelligence['isVpn']}");
      
      return true;
    } catch (e) {
      debugPrint("❌ Erreur inscription avec API: $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      bool isValid = await _databaseHelper.checkUserCredentials(normalizedEmail, password);
      if (isValid) {
        User? user = await _databaseHelper.getUserByEmail(normalizedEmail);
        currentUserId = user?.id;
        
        final userIp = await _apiService.getUserIp();
        final ipIntelligence = await _apiService.getIpIntelligence(userIp);
        
        if (ipIntelligence['isProxy'] == true || ipIntelligence['isVpn'] == true) {
          debugPrint("⚠️  Connexion suspecte détectée depuis IP: $userIp");
        }
        
        debugPrint("✅ Connexion réussie pour: $normalizedEmail");
      }
      return isValid;
    } catch (e) {
      debugPrint("❌ Erreur connexion: $e");
      return false;
    }
  }

  // MÉTHODES RÉCUPÉRATION MOT DE PASSE
  Future<Map<String, dynamic>> initiatePasswordRecovery(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      debugPrint("🔐 Initiation récupération mot de passe pour: $normalizedEmail");
      
      final result = await _passwordRecoveryService.sendRecoveryCode(normalizedEmail);
      return result;
    } catch (e) {
      debugPrint("❌ Erreur initiation récupération: $e");
      return {
        'success': false,
        'message': 'Erreur lors de la récupération',
      };
    }
  }

  Future<Map<String, dynamic>> verifyRecoveryCode(String email, String code) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      return await _passwordRecoveryService.verifyRecoveryCode(normalizedEmail, code);
    } catch (e) {
      debugPrint("❌ Erreur vérification code: $e");
      return {
        'success': false,
        'message': 'Erreur lors de la vérification',
      };
    }
  }

  Future<Map<String, dynamic>> resetPasswordWithCode(String email, String code, String newPassword) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      
      // Vérifier d'abord le code
      final verification = await _passwordRecoveryService.verifyRecoveryCode(normalizedEmail, code);
      
      if (!verification['success']) {
        return verification;
      }

      // Réinitialiser le mot de passe
      final recoveryId = verification['recoveryId'] as int;
      final result = await _passwordRecoveryService.resetPassword(
        normalizedEmail, 
        newPassword, 
        recoveryId.toString()
      );

      return result;
    } catch (e) {
      debugPrint("❌ Erreur réinitialisation mot de passe: $e");
      return {
        'success': false,
        'message': 'Erreur lors de la réinitialisation',
      };
    }
  }

  Future<void> cleanupRecoveryCodes() async {
    await _passwordRecoveryService.cleanupExpiredCodes();
  }

  // MÉTHODE debugCheckEmail AJOUTÉE
  Future<void> debugCheckEmail(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final exists = await _databaseHelper.isEmailExists(normalizedEmail);
      final allUsers = await _databaseHelper.getAllUsers();
      
      debugPrint("=== 🔍 DIAGNOSTIC EMAIL ===");
      debugPrint("Email original: $email");
      debugPrint("Email normalisé: $normalizedEmail");
      debugPrint("Existe dans DB: $exists");
      debugPrint("Utilisateurs en DB:");
      
      if (allUsers.isEmpty) {
        debugPrint("   Aucun utilisateur en base de données");
      } else {
        for (var user in allUsers) {
          debugPrint("   - '${user.email}' (ID: ${user.id}, Nom: ${user.name})");
        }
      }
      
      // Test de validation avec l'API
      debugPrint("--- TEST API VALIDATION ---");
      final apiValidation = await _apiService.validateEmail(email);
      debugPrint("API Validation - Valide: ${apiValidation['isValid']}");
      debugPrint("API Validation - Délivrable: ${apiValidation['isDeliverable']}");
      debugPrint("API Validation - Jetable: ${apiValidation['isDisposable']}");
      debugPrint("=== FIN DIAGNOSTIC ===");
    } catch (e) {
      debugPrint("❌ Erreur diagnostic email: $e");
    }
  }

  // Méthode pour corriger les avatars existants
  Future<void> fixExistingAvatars() async {
    try {
      final allUsers = await _databaseHelper.getAllUsers();
      int fixedCount = 0;
      
      for (var user in allUsers) {
        if (user.avatarInitials == null || user.avatarInitials!.isEmpty) {
          final newInitials = await _apiService.generateAvatarInitials(user.name);
          
          final updatedUser = User(
            id: user.id,
            name: user.name,
            email: user.email,
            phoneNumber: user.phoneNumber,
            gender: user.gender,
            password: user.password,
            avatarInitials: newInitials,
            registrationIp: user.registrationIp,
            registrationCountry: user.registrationCountry,
          );
          
          await _databaseHelper.updateUser(updatedUser);
          debugPrint("✅ Initiales ajoutées pour: ${user.name} -> $newInitials");
          fixedCount++;
        }
      }
      
      debugPrint("🎯 $fixedCount avatars corrigés avec succès!");
    } catch (e) {
      debugPrint("❌ Erreur correction avatars: $e");
    }
  }

  String _normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  Future<User?> getCurrentUser() async {
    if (currentUserId != null) {
      return await _databaseHelper.getUserById(currentUserId!);
    }
    return null;
  }

  Future<bool> updateProfile(User user) async {
    try {
      await _databaseHelper.updateUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount(int userId) async {
    try {
      await _databaseHelper.deleteUser(userId);
      currentUserId = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(int userId, String newPassword) async {
    try {
      User? user = await _databaseHelper.getUserById(userId);
      if (user != null) {
        user.password = newPassword;
        await _databaseHelper.updateUser(user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    currentUserId = null;
  }

  Future<void> debugApiUsage() async {
    final user = await getCurrentUser();
    if (user != null) {
      debugPrint("=== 📊 RAPPORT API UTILISATEUR ===");
      debugPrint("👤 Utilisateur: ${user.name}");
      debugPrint("📧 Email: ${user.email}");
      debugPrint("📞 Téléphone: ${user.phoneNumber}");
      debugPrint("🎨 Initiales: ${user.avatarInitials ?? 'Non généré'}");
      debugPrint("🌍 Pays d'inscription: ${user.registrationCountry ?? 'Inconnu'}");
      
      final currentIp = await _apiService.getUserIp();
      final ipInfo = await _apiService.getIpGeolocation(currentIp);
      debugPrint("🌍 Localisation actuelle: ${ipInfo['country']}");
      debugPrint("=== FIN RAPPORT ===");
    }
  }

  // MÉTHODE cleanDuplicateEmails AJOUTÉE
  Future<void> cleanDuplicateEmails() async {
    try {
      final allUsers = await _databaseHelper.getAllUsers();
      final emailCount = <String, int>{};
      
      for (var user in allUsers) {
        final normalized = _normalizeEmail(user.email);
        emailCount[normalized] = (emailCount[normalized] ?? 0) + 1;
      }
      
      debugPrint("=== 🧹 NETTOYAGE DOUBLONS ===");
      bool hasDuplicates = false;
      
      for (var entry in emailCount.entries) {
        if (entry.value > 1) {
          debugPrint("🚨 Doublon trouvé: '${entry.key}' (${entry.value} fois)");
          hasDuplicates = true;
        }
      }
      
      if (!hasDuplicates) {
        debugPrint("✅ Aucun doublon trouvé dans la base de données");
      }
      
      debugPrint("📊 Total utilisateurs uniques: ${emailCount.length}");
      debugPrint("=== FIN NETTOYAGE ===");
    } catch (e) {
      debugPrint("❌ Erreur nettoyage doublons: $e");
    }
  }
}