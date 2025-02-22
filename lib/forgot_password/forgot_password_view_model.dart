import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  String email = "";

  bool isLoading = false;

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }
}
