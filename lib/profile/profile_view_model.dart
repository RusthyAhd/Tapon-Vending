import 'package:flutter/material.dart';
import 'package:tapon_vending/profile/profile_model.dart';

class EditProfileViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  
  UserProfileModel user = UserProfileModel(
    name: '',
    email: '',
    mobile: '',
    password: '',
  );

  void updateUserProfile() {
    user = UserProfileModel(
      name: nameController.text,
      email: emailController.text,
      mobile: mobileController.text,
      password: user.password, // Keep existing password
    );

    notifyListeners(); // Notify UI to update
  }
}
