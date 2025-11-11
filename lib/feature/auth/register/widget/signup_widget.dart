import 'package:flutter/material.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/utils/snackbar_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/common/widget/form_validator.dart';
import 'package:ridesharing/feature/auth/login/login_page.dart';
import 'package:ridesharing/common/services/auth_service.dart';
import 'package:ridesharing/common/model/user_model.dart';
import 'package:ridesharing/common/widget/common_dropdown_box.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isValidating = false;
  String _validationMessage = '';

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      appBarTitle: "Sign Up",
      title: "Sign up with your email",
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                ReusableTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: nameController,
                  hintText: "Name",
                  validator: (value) =>
                      FormValidator.validateFieldNotEmpty(value, "Name"),
                ),
                ReusableTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: emailController,
                  hintText: "Email",
                  validator: (value) => FormValidator.validateEmail(value),
                ),
                ReusableTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: phoneNumberController,
                  hintText: "Phone Number",
                  validator: (value) => FormValidator.validatePhoneNumber(value),
                ),
                ReusableTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
                  controller: genderController,
                  hintText: "Gender",
                  validator: (value) =>
                      FormValidator.validateFieldNotEmpty(value, "Gender"),
                  readOnly: true,
                  onTap: () {
                    showPopUpMenuWithItems(
                      context: context,
                      title: "Select",
                      onItemPressed: (p0) {
                        genderController.text = p0;
                        setState(() {});
                      },
                      dataItems: gederList,
                    );
                  },
                ),
                ReusableTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                  validator: (value) =>
                      FormValidator.validateFieldNotEmpty(value, "Password"),
                ),
                ReusableTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                
                // INDICATEUR DE VALIDATION API
                if (_isValidating)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(
                          _validationMessage,
                          style: TextStyle(
                            color: CustomTheme.appColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomRoundedButtom(
                        title: "Sign Up",
                        onPressed: _signUp,
                      ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Divider(
                      thickness: 2,
                    ),
                    Container(
                      color: CustomTheme.lightColor,
                      width: 30.wp,
                      child: const Text(
                        "or",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginWidget(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(color: CustomTheme.appColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _isValidating = true;
        _validationMessage = 'Validation des informations...';
      });

      try {
        User newUser = User(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phoneNumber: phoneNumberController.text.trim(),
          gender: genderController.text,
          password: passwordController.text,
        );

        // Mise à jour des messages de validation
        setState(() {
          _validationMessage = 'Vérification de l\'email...';
        });
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _validationMessage = 'Vérification du téléphone...';
        });
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _validationMessage = 'Génération de l\'avatar...';
        });
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _validationMessage = 'Analyse de sécurité...';
        });

        bool success = await _authService.register(newUser);

        setState(() {
          _isLoading = false;
          _isValidating = false;
        });

        if (success) {
          SnackBarUtils.showSuccessBar(
            context: context,
            message: "Compte créé avec succès! ✅\nAvatar et sécurité activés",
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginWidget(),
            ),
          );
        } else {
          SnackBarUtils.showErrorBar(
            context: context,
            message: "Email existe déjà ou informations invalides",
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _isValidating = false;
        });
        SnackBarUtils.showErrorBar(
          context: context,
          message: "Erreur lors de la validation API. Réessayez.",
        );
      }
    }
  }

  final gederList = ["Male", "Female", "Other"];
}