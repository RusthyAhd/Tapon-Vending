import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tapon_vending/connect_to_machine.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String emailOrMobile = "";
  String password = "";
  bool rememberMe = false;
  bool isLoading = false;

  void toggleRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
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
    if (emailOrMobile.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    // Basic validation: require an email for email/password sign-in
    if (!emailOrMobile.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: emailOrMobile,
        password: password,
      );

      isLoading = false;
      notifyListeners();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConnectToMachinePage()),
      );
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Contact support.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'The password is incorrect. Try again.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check your connection and try again.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'This sign-in method is not enabled for your account.';
          break;
        default:
          errorMessage = 'Unable to sign in. Please try again.';
      }

      // Log for debugging
      // ignore: avoid_print
      print('Login error (${e.code}): ${e.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();
      // ignore: avoid_print
      print('Unexpected login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Something went wrong. Please try again.')),
      );
    }
  }
}
