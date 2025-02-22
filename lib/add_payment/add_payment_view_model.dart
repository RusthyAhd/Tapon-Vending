import 'package:flutter/material.dart';
import 'payment_method_model.dart';

class AddPaymentViewModel extends ChangeNotifier {
  List<PaymentMethod> paymentMethods = [
    PaymentMethod(type: "PayPal", logo: "assets/images/paypal.png"),
    PaymentMethod(type: "Visa", logo: "assets/images/visa.png"),
    PaymentMethod(type: "MasterCard", logo: "assets/images/image2.png"),
    PaymentMethod(type: "Discover", logo: "assets/images/icn.png"),
    PaymentMethod(type: "Amex", logo: "assets/images/amex.png"),
  ];

  PaymentMethod? selectedMethod;
  String cardNumber = "";
  String expiryMonth = "01";
  String expiryYear = "2024";
  String cvc = "";

  void selectMethod(int index) {
    selectedMethod = paymentMethods[index];
    notifyListeners();
  }

  void setCardNumber(String value) {
    cardNumber = value;
    notifyListeners();
  }

  void setExpiryMonth(String value) {
    expiryMonth = value;
    notifyListeners();
  }

  void setExpiryYear(String value) {
    expiryYear = value;
    notifyListeners();
  }

  void setCVC(String value) {
    cvc = value;
    notifyListeners();
  }
}
