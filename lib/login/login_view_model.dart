import 'package:flutter/material.dart';
import 'package:tapon_vending/home/home_view.dart';

class LoginViewModel extends ChangeNotifier {
  String emailOrMobile = "";
  String password = "";
  bool rememberMe = false;

  bool isLoading = false;

  void toggleRememberMe(bool value) {
    rememberMe = value;
    notifyListeners(); // Notifies UI to rebuild
  }

  void setEmailOrMobile(String value) {
    emailOrMobile = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulating API call

    isLoading = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful")));
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }
}
