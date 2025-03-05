// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SignupViewModel extends ChangeNotifier {
//   String name = "";
//   String email = "";
//   String mobile = "";
//   String password = "";
//   bool agreeToTerms = false;
//   bool isLoading = false;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void toggleAgreeToTerms(bool value) {
//     agreeToTerms = value;
//     notifyListeners();
//   }

// //  void setEmail(String value) {
// //     email = value;
// //     notifyListeners();
// //   }

// //   void setPassword(String value) {
// //     password = value;
// //     notifyListeners();
// //   }

// //   void setName(String value) {
// //     name = value;
// //     notifyListeners();
// //   }

// //   void setMobile(String value) {
// //     mobile = value;
// //     notifyListeners();
// //   }

//   Future<void> Signup(BuildContext context) async {
//   if (!agreeToTerms) {
//     print("⚠️ User did not agree to terms");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("You must agree to the terms and conditions.")),
//     );
//     return;
//   }

//   if (email.isEmpty || password.isEmpty) {
//     print("⚠️ Email or password is empty");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please fill in all fields")),
//     );
//     return;
//   }

//   try {
//     print("⏳ Signing up user with email: $email");

//     isLoading = true;
//     notifyListeners();

//     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     print("✅ User created: ${userCredential.user?.uid}");

//     isLoading = false;
//     notifyListeners();

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Signup Successful!")),
//     );

//     Navigator.pop(context);
//   } on FirebaseAuthException catch (e) {
//     isLoading = false;
//     notifyListeners();

//     print("❌ Firebase Auth Error: ${e.code}");

//     String errorMessage = "Signup failed";
//     if (e.code == 'email-already-in-use') {
//       errorMessage = "Email is already registered.";
//     } else if (e.code == 'weak-password') {
//       errorMessage = "Password is too weak.";
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(errorMessage)),
//     );
//   } catch (e) {
//     isLoading = false;
//     notifyListeners();

//     print("❌ Unexpected Error: $e");

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("An unexpected error occurred.")),
//     );
//   }
// }

// }import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tapon_vending/login/login_view.dart';

class SignupViewModel extends ChangeNotifier {
  String name = "";
  String email = "";
  String mobile = "";
  String password = "";
  bool agreeToTerms = false;
  bool isLoading = false;

  void toggleAgreeToTerms(bool value) {
    agreeToTerms = value;
    notifyListeners();
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

  /// ✅ Function to validate email format
  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  Future<void> signup(BuildContext context) async {
    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please agree to the terms and conditions")),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty || name.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      print("Signing up with email: $email and password: $password");

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": name,
          "email": email.trim(),
          "mobile": mobile,
          "userId": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
          "balance": 0, // Initial balance set to zero
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup Successful")),
        );

        print("User signed up successfully: ${user.uid}");

       Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.code} - ${e.message}")),
      );
    } catch (e) {
      print("Unexpected error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

//save user name
Future<void> saveUserName(String name) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
    });
  }
}