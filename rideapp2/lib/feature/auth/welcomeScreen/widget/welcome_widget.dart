import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/constant/assets.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/page_wrapper.dart';
import 'package:ridesharing/feature/auth/login/login_page.dart';
import 'package:ridesharing/feature/auth/register/screen/signup_page.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      padding: const EdgeInsets.all(22),
      body: SafeArea(
        child: Column(
          children: [
            // PARTIE HAUTE AVEC CONTENU SCROLLABLE
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildPage(
                  imageAsset: Assets.welcomeScreenImage,
                  title: "Welcome",
                  description: "Have a better sharing experience",
                ),
              ),
            ),
            
            // PARTIE BASSE FIXE AVEC LES BOUTONS
            Padding(
              padding: EdgeInsets.only(bottom: 10.hp),
              child: Column(
                children: [
                  CustomRoundedButtom(
                    title: "Create an account",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ));
                    },
                  ),
                  SizedBox(height: 12.hp),
                  CustomRoundedButtom(
                    color: Colors.transparent,
                    title: "Login",
                    textColor: CustomTheme.primaryColor,
                    borderColor: CustomTheme.primaryColor,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginWidget(),
                          ));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String imageAsset,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // IMAGE AVEC HAUTEUR ADAPTATIVE
        Container(
          margin: EdgeInsets.only(top: 40.hp, bottom: 30.hp),
          child: Image.asset(
            imageAsset,
            width: 280.wp,
            height: 280.hp,
            fit: BoxFit.contain,
          ),
        ),
        
        // CONTENU TEXTUEL
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.wp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: PoppinsTextStyles.titleMediumRegular.copyWith(
                  color: CustomTheme.darkerBlack,
                  fontSize: 28, // ✅ CORRIGÉ : Supprimé .sp
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.hp),
              Text(
                description,
                style: PoppinsTextStyles.subheadSmallRegular.copyWith(
                  fontSize: 16, // ✅ CORRIGÉ : Supprimé .sp
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 40.hp),
      ],
    );
  }
}