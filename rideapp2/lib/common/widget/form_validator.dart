import 'package:ridesharing/common/utils/text_utils.dart';

class FormValidator {
  // static String? validatePassword(String? val, {String? label}) {
  //   final RegExp _regex = RegExp(
  //       r"^.*(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!]).*$");
  //   if (val == null) {
  //     return LocaleKeys.fieldCannotBeEmpty
  //         .tr(args: [label ?? LocaleKeys.password.tr()]);
  //   } else if (val.isEmpty) {
  //     return LocaleKeys.fieldCannotBeEmpty
  //         .tr(args: [label ?? LocaleKeys.password.tr()]);
  //   } else if (_regex.hasMatch(val)) {
  //     return null;
  //   } else {
  //     return LocaleKeys.invalidPasswordMessage
  //         .tr(args: [label ?? LocaleKeys.password.tr()]);
  //   }
  // }

  static String? validatePhoneNumber(String? val) {
  // Validation plus flexible pour accepter différents formats
  final RegExp regExp = RegExp(r'^[0-9]{8,15}$');
  
  if (val == null || val.isEmpty) {
    return "Phone number cannot be empty.";
  } else {
    // Supprime tous les caractères non numériques
    final digitsOnly = val.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.length < 8) {
      return "Phone number must contain at least 8 digits";
    } else if (digitsOnly.length > 15) {
      return "Phone number is too long";
    } else if (!regExp.hasMatch(digitsOnly)) {
      return "Please enter a valid phone number";
    } else {
      return null;
    }
  }
}

  static String? validateFieldNotEmpty(String? value, String fieldName) {
    if (value == null) {
      return "$fieldName cannot be empty.";
    } else if (value.isEmpty) {
      return "$fieldName cannot be empty.";
      // return LocaleKeys.fieldCannotBeEmpty.tr(args: [fieldName]);
    } else {
      return null;
    }
  }

  static String? validateDateOfBirth(String? val) {
    if (val == null || val == "") {
      return "Date of birth field cannot be empty";
    } else if (val.isEmpty) {
      final DateTime dateTime = DateTime.parse(val);
      final maxDate = DateTime.now().year - 21;
      if (dateTime.year < maxDate) {
        return "Date of birth field cannot be empty";
      } else {
        return "Date of birth must be at least 21 years old";
      }
    } else {
      return null;
    }
  }

  static String? validateAmount(
      {required String val,
      required double minAmount,
      required double maxAmount}) {
    if (val.isEmpty) {
      return "Amount field cannot be empty";
    } else {
      double? amount = double.tryParse(val);
      if (amount == null) {
        return "Invalid amount";
      } else if (amount >= minAmount && amount <= maxAmount) {
        return null;
      } else {
        return "Amount must be between $minAmount and $maxAmount";
      }
    }
  }

  static String? validateEmail(String? val, [bool supportEmpty = false]) {
    if (supportEmpty && (val == null || val.isEmpty)) {
      return null;
    } else if (val == null) {
      // return LocaleKeys.fieldCannotBeEmpty.tr(args: [LocaleKeys.email.tr()]);
      return "Email Cannot be empty";
    } else if (val.isEmpty) {
      return "Email Cannot be empty";

      // return LocaleKeys.fieldCannotBeEmpty.tr(args: [LocaleKeys.email.tr()]);
    } else if (TextUtils.validateEmail(val)) {
      return null;
    } else {
      return "Please Enter a valid Email";

      // return LocaleKeys.pleaseEnterValidField.tr(args: [LocaleKeys.email.tr()]);
    }
  }
}
