class PaymentMethod {
  final String type; // Example: "Credit Card"
  final String lastFourDigits;
  final String logo;
  
  PaymentMethod({
    required this.type,
    required this.lastFourDigits,
    required this.logo,
  });
}
