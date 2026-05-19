import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tapon_vending/login/login_view.dart';
import 'package:tapon_vending/network/connectivity_service.dart';

class SignupViewModel extends ChangeNotifier {
  String name = "";
  String email = "";
  String mobile = "";
  String password = "";
  bool agreeToTerms = false;
  bool isLoading = false;
  String? errorMessage;

  void toggleAgreeToTerms(bool value) {
    agreeToTerms = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    errorMessage = null;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    errorMessage = null;
    notifyListeners();
  }

  void setName(String value) {
    name = value;
    errorMessage = null;
    notifyListeners();
  }

  void setMobile(String value) {
    mobile = value;
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  /// ✅ Function to validate email format
  bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Future<void> signup(BuildContext context) async {
    if (!agreeToTerms) {
      errorMessage = "Please agree to the terms and conditions";
      notifyListeners();
      return;
    }

    if (email.isEmpty || password.isEmpty || name.isEmpty || mobile.isEmpty) {
      errorMessage = "All fields are required";
      notifyListeners();
      return;
    }

    if (!isValidEmail(email)) {
      errorMessage = "Please enter a valid email address";
      notifyListeners();
      return;
    }

    if (password.length < 6) {
      errorMessage = "Password must be at least 6 characters long";
      notifyListeners();
      return;
    }

    if (mobile.length < 10) {
      errorMessage = "Please enter a valid phone number";
      notifyListeners();
      return;
    }

    try {
      await ConnectivityActionGuard.instance.run('signup', () async {
        isLoading = true;
        errorMessage = null;
        notifyListeners();

        print("Signing up with email: $email and password: $password");

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          await FirestoreOperationGuard.instance.runWrite('users:${user.uid}',
              () async {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .set({
              "name": name,
              "email": email.trim(),
              "mobile": mobile,
              "userId": user.uid,
              "createdAt": FieldValue.serverTimestamp(),
              "balance": 0, // Initial balance set to zero
            });
          });

          isLoading = false;
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Signup Successful"),
              backgroundColor: Colors.green,
            ),
          );

          print("User signed up successfully: ${user.uid}");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      });
    } on ConnectivityGuardException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } on FirebaseAuthException catch (e) {
      isLoading = false;

      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password is too weak. Use a stronger password.';
          break;
        case 'email-already-in-use':
          message = 'This email is already registered. Try logging in instead.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Sign up is currently disabled. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your connection and try again.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'Sign up failed. Please try again.';
      }

      errorMessage = message;
      notifyListeners();

      print("FirebaseAuthException: ${e.code} - ${e.message}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      isLoading = false;
      print("Unexpected error: $e");

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

//save user name
Future<void> saveUserName(String name) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirestoreOperationGuard.instance.runWrite('users:${user.uid}', () {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
      });
    });
  }
}
