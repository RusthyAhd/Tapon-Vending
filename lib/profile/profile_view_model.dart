import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tapon_vending/profile/profile_model.dart';
import 'package:tapon_vending/services/auth.dart';

class EditProfileViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  
    UserProfileModel? user;
  bool isLoading = true; 
  num balance = 0.0;

  EditProfileViewModel() {
    loadUserProfile();
  }
  
  // UserProfileModel user = UserProfileModel(
  //   name: '',
  //   email: '',
  //   mobile: '',
  //   password: '',
  // );
  // Load user data from Firebase
  Future<void> loadUserProfile() async {
    isLoading = true;
    notifyListeners();

    user = await _authService.getUserProfile();
    if (user != null) {
      nameController.text = user!.name;
      emailController.text = user!.email;
      mobileController.text = user!.mobile;
      // Fetch balance
      await _fetchBalance();
    }

    isLoading = false;
    notifyListeners();
  }
   // Fetch balance from Firestore
  Future<void> _fetchBalance() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (userDoc.exists) {
        balance = userDoc['balance'] ?? 0.0;
      }
    } catch (e) {
      print("Error fetching balance: $e");
    }
    notifyListeners();
  }
 // Update user data in Firebase
  Future<void> updateUserProfile() async {
    if (user == null) return;

    user = UserProfileModel(
      name: nameController.text,
      email: emailController.text,
      mobile: mobileController.text,
      password: user!.password,
    );

    await _authService.updateUserProfile(user!);
    notifyListeners();
  }
  // void updateUserProfile() {
  //   user = UserProfileModel(
  //     name: nameController.text,
  //     email: emailController.text,
  //     mobile: mobileController.text,
  //     password: user.password, // Keep existing password
  //   );

  //   notifyListeners(); // Notify UI to update
  // }

}

