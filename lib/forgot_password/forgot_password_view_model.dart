import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  String email = "";
  bool isLoading = false;


  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  Future<void> resetPassword(BuildContext context) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password reset email sent!")));
      Navigator.pop(context); // Go back to login screen
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
    }

    isLoading = false;
    notifyListeners();
  }
}
