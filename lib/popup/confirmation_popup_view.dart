import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'confirmation_view_model.dart';

class ConfirmationPopup extends StatelessWidget {
  ConfirmationPopup({Key? key}) : super(key: key);

  final ConfirmationViewModel viewModel = Get.put(ConfirmationViewModel());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Obx(() => Text(
            viewModel.confirmationData.value.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
      content: Obx(() => Text(viewModel.confirmationData.value.message)),
      actions: [
        TextButton(
          onPressed: viewModel.onCancel,
          child: Obx(() => Text(
                viewModel.confirmationData.value.cancelText,
                style: const TextStyle(color: Colors.red),
              )),
        ),
        TextButton(
          onPressed: viewModel.onConfirm,
          child: Obx(() => Text(
                viewModel.confirmationData.value.confirmText,
                style: const TextStyle(color: Colors.green),
              )),
        ),
      ],
    );
  }
}

