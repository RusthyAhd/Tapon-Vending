import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:tapon_vending/connect_to_machine.dart';
import 'package:tapon_vending/home/home_view.dart';
import 'package:tapon_vending/services/google_sign_in_service.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  late SharedPreferences _prefs;

  String emailOrMobile = "";
  String password = "";
  bool rememberMe = false;
  bool isLoading = false;
  String? errorMessage;

  // Key constants for SharedPreferences
  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';
  static const String _rememberMeKey = 'remember_me';

  LoginViewModel() {
    _initializePreferences();
  }

  // Initialize SharedPreferences and load saved credentials
  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedCredentials();
  }

  // Load saved credentials from local storage
  void _loadSavedCredentials() {
    final savedEmail = _prefs.getString(_emailKey) ?? '';
    final savedPassword = _prefs.getString(_passwordKey) ?? '';
    final savedRememberMe = _prefs.getBool(_rememberMeKey) ?? false;

    if (savedRememberMe && savedEmail.isNotEmpty) {
      emailOrMobile = savedEmail;
      password = savedPassword;
      rememberMe = true;
      notifyListeners();
    }
  }

  // Save credentials when Remember Me is enabled
  Future<void> _saveCredentials() async {
    if (rememberMe) {
      await _prefs.setString(_emailKey, emailOrMobile);
      await _prefs.setString(_passwordKey, password);
      await _prefs.setBool(_rememberMeKey, true);
    } else {
      // Clear saved credentials if Remember Me is unchecked
      await _prefs.remove(_emailKey);
      await _prefs.remove(_passwordKey);
      await _prefs.setBool(_rememberMeKey, false);
    }
  }

  void toggleRememberMe(bool value) {
    rememberMe = value;
    _saveCredentials();
    notifyListeners();
  }

  void setEmailOrMobile(String value) {
    emailOrMobile = value;
    errorMessage = null;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _isUserBlocked() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data();
    if (data == null) return false;

    return (data['isBlocked'] as bool?) ?? false;
  }

  Future<void> _showBlockedDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account Blocked'),
          content: const Text(
              'Your account has been blocked. Please contact support.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> login(BuildContext context) async {
    // Validate inputs
    if (emailOrMobile.isEmpty || password.isEmpty) {
      errorMessage = "All fields are required";
      notifyListeners();
      return;
    }

    // Basic validation: require an email for email/password sign-in
    if (!emailOrMobile.contains('@')) {
      errorMessage = "Please enter a valid email address.";
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: emailOrMobile,
        password: password,
      );

      final isBlocked = await _isUserBlocked();
      if (isBlocked) {
        await _auth.signOut();
        isLoading = false;
        notifyListeners();
        await _showBlockedDialog(context);
        return;
      }

      // Save credentials if Remember Me is checked
      if (rememberMe) {
        await _saveCredentials();
      }

      isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Contact support.';
          break;
        case 'user-not-found':
          message = 'No account found for this email.';
          break;
        case 'wrong-password':
          message = 'The password is incorrect. Try again.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your connection and try again.';
          break;
        case 'operation-not-allowed':
          message = 'This sign-in method is not enabled for your account.';
          break;
        default:
          message = 'Unable to sign in. Please try again.';
      }

      errorMessage = message;
      // ignore: avoid_print
      print('Login error (${e.code}): ${e.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      isLoading = false;
      // ignore: avoid_print
      print('Unexpected login error: $e');

      errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final user = await _googleSignInService.signInWithGoogle();
      if (user == null) {
        isLoading = false;
        errorMessage = 'Google Sign-In cancelled.';
        notifyListeners();
        return;
      }

      final isBlocked = await _isUserBlocked();
      if (isBlocked) {
        await _googleSignInService.signOut();
        isLoading = false;
        notifyListeners();
        await _showBlockedDialog(context);
        return;
      }

      isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message =
              'An account already exists with a different sign-in method.';
          break;
        case 'invalid-credential':
          message = 'Invalid Google credentials. Please try again.';
          break;
        case 'operation-not-allowed':
          message = 'Google Sign-In is not enabled.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Contact support.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your connection and try again.';
          break;
        default:
          message = 'Unable to sign in with Google. Please try again.';
      }

      errorMessage = message;
      // ignore: avoid_print
      print('Google Sign-In error (${e.code}): ${e.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      isLoading = false;
      // ignore: avoid_print
      print('Unexpected Google Sign-In error: $e');

      errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
