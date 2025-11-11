import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/constant/assets.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/common_popup_box.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/services/auth_service.dart';
import 'package:ridesharing/feature/auth/register/screen/signup_page.dart';

class DeleteAccountWidget extends StatelessWidget {
  const DeleteAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return CommonContainer(
      appBarTitle: "Delete Account",
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.wp, vertical: 20.hp),
        child: Column(
          children: [
            // Icon d'avertissement
            Container(
              width: 80.wp,
              height: 80.hp,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  CustomTheme.googleColor.withOpacity(0.1),
                  Colors.white,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 40.wp,
                color: CustomTheme.googleColor,
              ),
            ),
            SizedBox(height: 24.hp),
            
            // Titre principal
            Text(
              "Delete Your Account?",
              style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                color: Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.hp),
            
            // Carte d'information
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.wp),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.orange.shade600,
                        size: 20.wp,
                      ),
                      SizedBox(width: 8.wp),
                      Text(
                        "Important Information",
                        style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.hp),
                  Text(
                    "Are you sure you want to delete your account? Please read how account deletion will affect you.",
                    style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 12.hp),
                  _buildInfoItem(
                    Icons.email_outlined,
                    "Email Permanently Reserved",
                    "Your email becomes permanently reserved and cannot be re-used to register a new account.",
                  ),
                  SizedBox(height: 8.hp),
                  _buildInfoItem(
                    Icons.delete_outline_rounded,
                    "Data Removal",
                    "All your personal information will be permanently removed from our database.",
                  ),
                  SizedBox(height: 8.hp),
                  _buildInfoItem(
                    Icons.block_rounded,
                    "Irreversible Action",
                    "This action cannot be undone. Once deleted, you cannot recover your account.",
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.hp),
            
            // Bouton de suppression
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.wp),
              child: CustomRoundedButtom(
                title: "Delete My Account",
                color: CustomTheme.googleColor,
                textColor: Colors.white,
                onPressed: () {
                  _showDeleteConfirmationDialog(context, authService);
                },
              ),
            ),
            SizedBox(height: 16.hp),
            
            // Lien d'annulation
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 16.wp,
        ),
        SizedBox(width: 8.wp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.hp),
              Text(
                description,
                style: PoppinsTextStyles.bodyMediumRegular.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, AuthService authService) {
    showCommonPopUpDialog(
      context: context,
      title: "Confirm Account Deletion",
      message: "This action is permanent and cannot be undone. All your data will be permanently deleted from our systems.",
      enableButtonName: "Yes, Delete Account",
      disableButtonName: "Cancel",
      imageUrl: Assets.successAlertImage,
      onEnablePressed: () async {
        final navigator = Navigator.of(context, rootNavigator: true);
        
        bool success = await authService.deleteAccount(AuthService.currentUserId!);
        
        // Fermez TOUTES les boîtes de dialogue d'abord
        navigator.pop();
        
        // Utilisez un délai pour assurer que la navigation est terminée
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (success) {
          _navigateToSignUp(navigator);
        } else {
          _showErrorDialog(navigator.context);
        }
      },
      onDisablePressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }

  void _navigateToSignUp(NavigatorState navigator) {
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignUpPage()),
      (route) => false,
    );
  }

  void _showErrorDialog(BuildContext context) {
    // Attendez un peu avant d'afficher le dialogue d'erreur
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        showCommonPopUpDialog(
          imageUrl: Assets.successAlertImage,
          context: context,
          title: "Deletion Failed",
          message: "We couldn't delete your account at this time. Please check your connection and try again.",
          enableButtonName: "OK",
          disableButtonName: "",
          onEnablePressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          onDisablePressed: () {},
        );
      }
      
    });
  }
}