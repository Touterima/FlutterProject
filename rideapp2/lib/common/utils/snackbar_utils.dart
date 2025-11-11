import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/theme.dart';

class SnackBarUtils {
  static void showSuccessBar(
      {required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CustomTheme.green,
        content: Text(
          message,
          style: PoppinsTextStyles.bodySmallRegular.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static void showErrorBar(
      {required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CustomTheme.primaryColor,
        content: Text(
          message,
          style: PoppinsTextStyles.bodySmallRegular.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

// AJOUTEZ cette méthode dans votre classe SnackBarUtils :

static void showInfoBar({
  required BuildContext context,
  required String message,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
}
