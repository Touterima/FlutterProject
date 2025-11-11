import 'dart:math';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class PasswordRecoveryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Generate a random 6-digit recovery code
  String generateRecoveryCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send recovery code (in a real app, this would send an email/SMS)
  /// For now, we'll just store it in the database and return it for testing
  Future<Map<String, dynamic>> sendRecoveryCode(String email) async {
    try {
      // Check if user exists
      final user = await _databaseHelper.getUserByEmail(email);
      
      if (user == null) {
        return {
          'success': false,
          'message': 'No account found with this email address',
        };
      }

      // Generate recovery code
      final code = generateRecoveryCode();
      
      // Set expiration time (15 minutes from now)
      final expiration = DateTime.now().add(const Duration(minutes: 15));

      // Store recovery code in database
      await _databaseHelper.insertPasswordRecoveryCode(
        email,
        code,
        expiration,
      );

      if (kDebugMode) {
        print('🔐 Recovery code generated for $email: $code');
        print('⏰ Expires at: $expiration');
      }

      // In a real app, you would send this code via email/SMS
      // For testing, we return it in the response
      return {
        'success': true,
        'message': 'Recovery code sent successfully',
        'code': code, // Remove this in production!
        'email': email,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending recovery code: $e');
      }
      return {
        'success': false,
        'message': 'Failed to send recovery code: $e',
      };
    }
  }

  /// Verify the recovery code
  Future<Map<String, dynamic>> verifyRecoveryCode(
    String email,
    String code,
  ) async {
    try {
      // Get valid recovery code from database
      final recovery = await _databaseHelper.getValidRecoveryCode(email, code);

      if (recovery == null) {
        return {
          'success': false,
          'message': 'Invalid or expired recovery code',
        };
      }

      if (kDebugMode) {
        print('✅ Recovery code verified for $email');
      }

      return {
        'success': true,
        'message': 'Recovery code verified successfully',
        'email': email,
        'code': code,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying recovery code: $e');
      }
      return {
        'success': false,
        'message': 'Failed to verify recovery code: $e',
      };
    }
  }

  /// Reset password with verified code
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      // Verify the code is still valid
      final recovery = await _databaseHelper.getValidRecoveryCode(email, code);

      if (recovery == null) {
        return {
          'success': false,
          'message': 'Invalid or expired recovery code',
        };
      }

      // Get user
      final user = await _databaseHelper.getUserByEmail(email);
      
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      // Update password
      user.password = newPassword;
      await _databaseHelper.updateUser(user);

      // Mark recovery code as used
      await _databaseHelper.markRecoveryCodeAsUsed(email, code);

      if (kDebugMode) {
        print('✅ Password reset successfully for $email');
      }

      return {
        'success': true,
        'message': 'Password reset successfully',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting password: $e');
      }
      return {
        'success': false,
        'message': 'Failed to reset password: $e',
      };
    }
  }

  /// Clean up expired recovery codes
  Future<void> cleanupExpiredCodes() async {
    try {
      await _databaseHelper.cleanupExpiredRecoveryCodes();
      
      if (kDebugMode) {
        print('🧹 Expired recovery codes cleaned up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cleaning up expired codes: $e');
      }
    }
  }

  /// Validate password strength
  Map<String, dynamic> validatePassword(String password) {
    if (password.length < 8) {
      return {
        'valid': false,
        'message': 'Password must be at least 8 characters long',
      };
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return {
        'valid': false,
        'message': 'Password must contain at least one uppercase letter',
      };
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return {
        'valid': false,
        'message': 'Password must contain at least one lowercase letter',
      };
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return {
        'valid': false,
        'message': 'Password must contain at least one number',
      };
    }

    return {
      'valid': true,
      'message': 'Password is strong',
    };
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      return await _databaseHelper.isEmailExists(email);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking email: $e');
      }
      return false;
    }
  }
}