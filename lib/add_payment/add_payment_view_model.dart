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

  int selectedMethodIndex = -1;

  void selectMethod(int index) {
    for (var i = 0; i < paymentMethods.length; i++) {
      paymentMethods[i].isSelected = i == index;
    }
    selectedMethodIndex = index;
    notifyListeners();
  }
}
