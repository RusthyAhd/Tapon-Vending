import 'dart:ui';

import 'package:get/get.dart';
import 'confirmation_model.dart';

class ConfirmationViewModel extends GetxController {
  final confirmationData = ConfirmationModel(
    title: "Confirm Order Now?",
    message: "Your order will be confirmed from your account.",
    confirmText: "Confirm",
    cancelText: "Cancel",
  ).obs;

  late VoidCallback onConfirmCallback;

  void onConfirm() {
    // Call the callback function when confirmed
    if (onConfirmCallback != null) {
      onConfirmCallback();
    }
  }

  void onCancel() {
    Get.back(result: false);
  }

  void setConfirmCallback(VoidCallback callback) {
    onConfirmCallback = callback;
  }
}
