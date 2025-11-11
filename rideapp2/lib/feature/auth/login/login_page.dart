import 'package:flutter/material.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/utils/snackbar_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/common/widget/form_validator.dart';
import 'package:ridesharing/feature/auth/register/screen/signup_page.dart';
import 'package:ridesharing/feature/dashboard/dashboard_widget.dart';
import 'package:ridesharing/common/services/auth_service.dart';
import 'package:ridesharing/feature/auth/password_recovery/screens/forgot_password_page.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      appBarTitle: "Sign In",
      title: "Sign in with your email",
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            ReusableTextField(
              validator: (value) =>
                  FormValidator.validateFieldNotEmpty(value, "Email"),
              controller: emailController,
              hintText: "Email",
            ),
            ReusableTextField(
              validator: (value) =>
                  FormValidator.validateFieldNotEmpty(value, "Password"),
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),
            Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordPage(),
            ),
          );
        },
        child: const Text(
          "Mot de passe oublié ?",
          style: TextStyle(
            color: CustomTheme.appColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomRoundedButtom(
                    title: "Sign In",
                    onPressed: _signIn,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Don\'t have an account? ',
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
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
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool success = await _authService.login(
          emailController.text.trim(),
          passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardWidget(),
            ),
            (route) => false,
          );
        } else {
          SnackBarUtils.showErrorBar(
            context: context,
            message: "Invalid email or password",
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        SnackBarUtils.showErrorBar(
          context: context,
          message: "An error occurred. Please try again.",
        );
      }
    }
  }
}