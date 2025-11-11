import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AbstractApiService {
  // Clés API pour chaque service
  static const String EMAIL_API_KEY = "c160bf24d3cf49ba8038e2299b2b1200";
  static const String PHONE_API_KEY = "919a5d13c48a4bd1aa68a7779b5e2a98";
  static const String IP_INTELLIGENCE_API_KEY = "a79807a65c164c92916180dde0a4c643";
  static const String IP_GEOLOCATION_API_KEY = "4e211f0e258e4d65b1922caad99ac067";

  // 1. VALIDATION EMAIL - VERSION CORRIGÉE
  Future<Map<String, dynamic>> validateEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('https://emailreputation.abstractapi.com/v1/?api_key=$EMAIL_API_KEY&email=$email'),
      );

      debugPrint("📧 Email Validation Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("📧 Email Validation Full Response: ${json.encode(data)}");
        
        // EXTRACTION SÉCURISÉE DES DONNÉES
        final deliverability = data['email_deliverability'];
        final quality = data['email_quality'];
        
        // VÉRIFICATIONS SÉCURISÉES
        bool isFormatValid = deliverability != null && 
                            deliverability['is_format_valid'] == true;
        
        bool isDisposable = quality != null && 
                           quality['is_disposable'] == true;
        
        bool isDeliverable = deliverability != null && 
                            deliverability['status'] == 'deliverable';
        
        bool isSmtpValid = deliverability != null && 
                          deliverability['is_smtp_valid'] == true;

        bool isValid = isFormatValid && !isDisposable;

        return {
          'isValid': isValid,
          'isDeliverable': isDeliverable,
          'isDisposable': isDisposable,
          'isFormatValid': isFormatValid,
          'isSmtpValid': isSmtpValid,
          'deliverabilityStatus': deliverability != null ? deliverability['status'] : 'unknown',
          'qualityScore': quality != null ? quality['score']?.toString() ?? 'N/A' : 'N/A',
        };
      } else {
        debugPrint("❌ Email API Error: ${response.statusCode}");
        return {
          'isValid': false, 
          'error': 'API Error - Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint("❌ Email validation error: $e");
      return {
        'isValid': false, 
        'error': e.toString()
      };
    }
  }

  // 2. VALIDATION TÉLÉPHONE
  Future<Map<String, dynamic>> validatePhone(String phone, String countryCode) async {
    try {
      final response = await http.get(
        Uri.parse('https://phoneintelligence.abstractapi.com/v1/?api_key=$PHONE_API_KEY&phone=$phone&country_code=$countryCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("📱 Phone Validation RAW: ${json.encode(data)}");
        
        final validation = data['phone_validation'];
        final carrier = data['phone_carrier'];
        final risk = data['phone_risk'];
        final location = data['phone_location'];
        
        bool isValid = validation != null && validation['is_valid'] == true;
        bool isActive = validation != null && validation['line_status'] == 'active';
        bool isMobile = carrier != null && carrier['line_type'] == 'mobile';
        bool isNotVoip = validation != null && validation['is_voip'] == false;
        bool isNotDisposable = risk != null && risk['is_disposable'] == false;
        String lineType = carrier != null ? carrier['line_type'] : 'unknown';
        String carrierName = carrier != null ? carrier['name'] : 'Unknown';
        String countryName = location != null ? location['country_name'] : 'Unknown';
        String riskLevel = risk != null ? risk['risk_level'] : 'unknown';

        return {
          'isValid': isValid,
          'isActive': isActive,
          'isMobile': isMobile,
          'isNotVoip': isNotVoip,
          'isNotDisposable': isNotDisposable,
          'type': lineType,
          'carrier': carrierName,
          'country': countryName,
          'riskLevel': riskLevel,
        };
      }
      return {
        'isValid': false, 
        'error': 'API Error - Status: ${response.statusCode}'
      };
    } catch (e) {
      debugPrint("❌ Phone validation error: $e");
      return {
        'isValid': false, 
        'error': e.toString()
      };
    }
  }

  // 3. GÉNÉRATION D'INITIALES POUR AVATAR
  Future<String> generateAvatarInitials(String name) async {
    final initials = _getInitials(name);
    debugPrint("🎨 Initiales générées: $initials pour $name");
    return initials;
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 3) {
      return '${names[0][0]}${names[1][0]}${names[2][0]}'.toUpperCase();
    } else if (names.length == 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.length == 1 && names[0].length >= 2) {
      return names[0].substring(0, 2).toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  // 4. INTELLIGENCE IP
  Future<Map<String, dynamic>> getIpIntelligence(String ipAddress) async {
    try {
      final response = await http.get(
        Uri.parse('https://ip-intelligence.abstractapi.com/v1/?api_key=$IP_INTELLIGENCE_API_KEY&ip_address=$ipAddress'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("🛡️ IP Intelligence Result: $data");
        
        return {
          'isProxy': data['is_proxy'] ?? false,
          'isVpn': data['is_vpn'] ?? false,
          'isTor': data['is_tor'] ?? false,
          'isBot': data['is_bot'] ?? false,
          'riskScore': data['risk_score'] ?? 0,
          'threatType': data['threat_type'] ?? 'none',
        };
      }
      return {'isProxy': false, 'riskScore': 0};
    } catch (e) {
      debugPrint("❌ IP Intelligence error: $e");
      return {'isProxy': false, 'riskScore': 0};
    }
  }

  // 5. GÉOLOCALISATION IP
  Future<Map<String, dynamic>> getIpGeolocation(String ipAddress) async {
    try {
      final response = await http.get(
        Uri.parse('https://ipgeolocation.abstractapi.com/v1/?api_key=$IP_GEOLOCATION_API_KEY&ip_address=$ipAddress'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("🌍 IP Geolocation Result: $data");
        
        return {
          'country': data['country'] ?? 'Unknown',
          'city': data['city'] ?? 'Unknown',
          'region': data['region'] ?? 'Unknown',
          'latitude': data['latitude']?.toString() ?? '0',
          'longitude': data['longitude']?.toString() ?? '0',
          'timezone': data['timezone']?['name'] ?? 'UTC',
        };
      }
      return {'country': 'Unknown', 'city': 'Unknown'};
    } catch (e) {
      debugPrint("❌ IP Geolocation error: $e");
      return {'country': 'Unknown', 'city': 'Unknown'};
    }
  }

  // Méthode utilitaire pour obtenir l'IP
  Future<String> getUserIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body;
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
}