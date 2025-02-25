import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'confirmation_model.dart';
import 'package:tapon_vending/home/home_view.dart';

class ConfirmationViewModel extends GetxController {
  final confirmationData = ConfirmationModel(
    title: "Confirm Order Now?",
    message: "Your order will be confirmed from your account.",
    confirmText: "Confirm",
    cancelText: "Cancel",
  ).obs;

  void onConfirm() {
    // Handle confirm logic (e.g., API call, local state change)
    Get.back(result: true);
  }

  void onCancel(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
