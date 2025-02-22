import 'package:flutter/material.dart';
import 'package:tapon_vending/payment_method/payment_method_model.dart';


class PaymentViewModel extends ChangeNotifier {
  List<PaymentMethod> _methods = [
    PaymentMethod(type: "Credit Card", lastFourDigits: "1234", logo: "assets/images/image2.png"),
  ];

  List<PaymentMethod> get methods => _methods;

  void addPaymentMethod(PaymentMethod method) {
    _methods.add(method);
    notifyListeners();
  }

  void removePaymentMethod(int index) {
    _methods.removeAt(index);
    notifyListeners();
  }
}
