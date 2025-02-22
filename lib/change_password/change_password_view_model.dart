import 'package:flutter/material.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  bool isPasswordValid = false;

  void updateOldPassword(String value) {
    oldPassword = value;
    notifyListeners();
  }

  void updateNewPassword(String value) {
    newPassword = value;
    _validatePassword();
  }

  void updateConfirmPassword(String value) {
    confirmPassword = value;
    _validatePassword();
  }

  void _validatePassword() {
    // Basic example checks:
    // - Minimum length of 8
    // - Contains at least one digit
    // - Contains at least one special character
    // - New and confirm match
    isPasswordValid = newPassword.length >= 8 &&
        RegExp(r'\d').hasMatch(newPassword) && 
        RegExp(r'[!@#\$%\^&\*]').hasMatch(newPassword) &&
        newPassword == confirmPassword;

    notifyListeners();
  }

  Future<void> updatePassword() async {
    if (isPasswordValid) {
      // Perform your backend request here
      // e.g., calling an API to update the password
      // For demonstration, we just print a success message
      print("Password updated successfully!");
    } else {
      print("Password does not meet the requirements.");
    }
  }
}
