import 'package:flutter/material.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/snackbar_utils.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/common/widget/form_validator.dart';
import 'package:ridesharing/feature/auth/login/login_page.dart';
import 'package:ridesharing/common/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _authService = AuthService();
  final _emailFormKey = GlobalKey<FormState>(); // ✅ CLÉ SÉPARÉE POUR EMAIL
  final _passwordFormKey = GlobalKey<FormState>(); // ✅ CLÉ SÉPARÉE POUR PASSWORD
  
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0;
  String? _userEmail;
  String? _recoveryCode;

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.lightColor,
      appBar: AppBar(
        title: const Text("Mot de Passe Oublié"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginWidget()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildStepIndicator(),
              const SizedBox(height: 30),
              Expanded(
                child: _buildCurrentStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepCircle(0, "Email"),
        _buildStepConnector(),
        _buildStepCircle(1, "Code"),
        _buildStepConnector(),
        _buildStepCircle(2, "Mot de passe"),
      ],
    );
  }

  Widget _buildStepCircle(int stepNumber, String label) {
    final isActive = _currentStep == stepNumber;
    final isCompleted = _currentStep > stepNumber;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive || isCompleted 
                ? CustomTheme.appColor 
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    (stepNumber + 1).toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? CustomTheme.appColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Expanded(
      child: Container(
        height: 2,
        color: Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildCodeStep();
      case 2:
        return _buildPasswordStep();
      default:
        return _buildEmailStep();
    }
  }

  Widget _buildEmailStep() {
    return SingleChildScrollView(
      child: Form(
        key: _emailFormKey, // ✅ CLÉ UNIQUE POUR CET ÉTAPE
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Réinitialisation du mot de passe",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Entrez votre adresse email pour recevoir un code de récupération",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ReusableTextField(
              controller: emailController,
              hintText: "Adresse Email",
              validator: (value) => FormValidator.validateEmail(value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomRoundedButtom(
                    title: "Envoyer le Code",
                    onPressed: _sendRecoveryCode,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vérification du code",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Entrez le code de récupération envoyé à votre email",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: codeController,
            decoration: const InputDecoration(
              hintText: "Code à 6 chiffres",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomRoundedButtom(
                  title: "Vérifier le Code",
                  onPressed: _verifyRecoveryCode,
                ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: _resendCode,
              child: const Text(
                "Renvoyer le code",
                style: TextStyle(
                  color: CustomTheme.appColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      child: Form(
        key: _passwordFormKey, // ✅ CLÉ UNIQUE POUR CET ÉTAPE
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nouveau mot de passe",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Créez votre nouveau mot de passe",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ReusableTextField(
              controller: newPasswordController,
              hintText: "Nouveau mot de passe",
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez entrer un mot de passe";
                }
                if (value.length < 6) {
                  return "Le mot de passe doit contenir au moins 6 caractères";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ReusableTextField(
              controller: confirmPasswordController,
              hintText: "Confirmer le mot de passe",
              obscureText: true,
              validator: (value) {
                if (value != newPasswordController.text) {
                  return "Les mots de passe ne correspondent pas";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomRoundedButtom(
                    title: "Réinitialiser le Mot de Passe",
                    onPressed: _resetPassword,
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendRecoveryCode() async {
    if (_emailFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.initiatePasswordRecovery(
          emailController.text.trim(),
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          _userEmail = emailController.text.trim();
          _recoveryCode = result['code'];
          
          SnackBarUtils.showSuccessBar(
            context: context,
            message: result['message'],
          );
          
          // Afficher le code en debug
          if (_recoveryCode != null) {
            debugPrint("🔐 CODE DE RÉCUPÉRATION: $_recoveryCode");
            SnackBarUtils.showInfoBar(
              context: context,
              message: "Code debug: $_recoveryCode",
            );
          }
          
          setState(() {
            _currentStep = 1;
          });
        } else {
          SnackBarUtils.showErrorBar(
            context: context,
            message: result['message'],
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        SnackBarUtils.showErrorBar(
          context: context,
          message: "Erreur lors de l'envoi du code",
        );
      }
    }
  }

  Future<void> _verifyRecoveryCode() async {
    if (codeController.text.length != 6) {
      SnackBarUtils.showErrorBar(
        context: context,
        message: "Veuillez entrer un code à 6 chiffres",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.verifyRecoveryCode(
        _userEmail!,
        codeController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        SnackBarUtils.showSuccessBar(
          context: context,
          message: result['message'],
        );
        
        setState(() {
          _currentStep = 2;
        });
      } else {
        SnackBarUtils.showErrorBar(
          context: context,
          message: result['message'],
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      SnackBarUtils.showErrorBar(
        context: context,
        message: "Erreur lors de la vérification",
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.resetPasswordWithCode(
          _userEmail!,
          codeController.text,
          newPasswordController.text,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          SnackBarUtils.showSuccessBar(
            context: context,
            message: "Mot de passe réinitialisé avec succès!",
          );
          
          // Rediriger vers la page de connexion
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginWidget()),
              (route) => false,
            );
          }
        } else {
          SnackBarUtils.showErrorBar(
            context: context,
            message: result['message'],
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        SnackBarUtils.showErrorBar(
          context: context,
          message: "Erreur lors de la réinitialisation",
        );
      }
    }
  }

  Future<void> _resendCode() async {
    if (_userEmail == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.initiatePasswordRecovery(_userEmail!);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        _recoveryCode = result['code'];
        
        SnackBarUtils.showSuccessBar(
          context: context,
          message: "Nouveau code envoyé!",
        );
        
        // Afficher le nouveau code en debug
        if (_recoveryCode != null) {
          debugPrint("🔐 NOUVEAU CODE: $_recoveryCode");
          SnackBarUtils.showInfoBar(
            context: context,
            message: "Nouveau code debug: $_recoveryCode",
          );
        }
      } else {
        SnackBarUtils.showErrorBar(
          context: context,
          message: result['message'],
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      SnackBarUtils.showErrorBar(
        context: context,
        message: "Erreur lors de l'envoi",
      );
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginWidget()),
      );
    }
  }
}