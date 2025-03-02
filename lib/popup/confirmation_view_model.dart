
import 'package:get/get.dart';

import 'confirmation_model.dart';

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

  void onCancel() {
    Get.back(result: false);
  }
}