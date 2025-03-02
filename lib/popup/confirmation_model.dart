class ConfirmationModel {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  ConfirmationModel({
    required this.title,
    required this.message,
    this.confirmText = "Confirm",
    this.cancelText = "Cancel",
  });
}

