import 'package:flutter/material.dart';

class SignupViewModel extends ChangeNotifier {
  String name = ""; 
  String email = "";
  String mobile ="";
  String password = "";
  bool agreeToTerms = false;

  bool isLoading = false;

  void toggleAgreeToTerms(bool value) {
    agreeToTerms = value;
    notifyListeners(); // Notifies UI to rebuild
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }
   void setName(String value) {
    name = value;
    notifyListeners();
  }
 void setMobile(String value) {
    mobile = value;
    notifyListeners();
  }


  Future<void> Signup(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulating API call

    isLoading = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signup Successful")));
  }
}
