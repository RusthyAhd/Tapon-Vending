class PaymentMethod {
  String type;
  String logo;
  bool isSelected;

  PaymentMethod({required this.type, required this.logo, this.isSelected = false});
}
