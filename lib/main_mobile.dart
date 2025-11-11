import 'package:flutter/material.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/feature/onbaording/splash_screen.dart';
import 'package:ridesharing/common/database/database_helper.dart';
import 'package:ridesharing/common/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TEST DIRECT DE LA BASE DE DONNÉES - DÉCOMMENTEZ POUR VOIR LES UTILISATEURS
  print("🚀 DÉMARRAGE DE L'APPLICATION");
  print("🔍 TEST DE LA BASE DE DONNÉES...");
  
  try {
    await DatabaseHelper().debugPrintAllUsers();
    
    // Testez aussi avec un email spécifique
    await AuthService().debugCheckEmail("test@example.com");
    
    print("✅ Test de la base de données terminé");
  } catch (e) {
    print("❌ Erreur lors du test de la base de données: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: CustomTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashWidget());
  }
}