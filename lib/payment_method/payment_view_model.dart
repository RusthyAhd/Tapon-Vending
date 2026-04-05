import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tapon_vending/payment_method/payment_method_model.dart';


class PaymentViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  num balance = 0.0;
  bool isLoading = true;

  PaymentViewModel() {
    fetchBalance();
  }
   

    Future<void> fetchBalance() async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('balance')) {
          balance = (data['balance'] ?? 0).toDouble();
        } else {
          // If 'balance' field is missing, set it to 0 in Firestore
          await docRef.update({'balance': 0});
          balance = 0;
        }
      } else {
        print("User document does not exist!");
      }
    }
  } catch (e) {
    print("Error fetching balance: $e");
  }

  isLoading = false;
  notifyListeners();
}

  List<PaymentMethod> _methods = [
    PaymentMethod(type: "Credit Card", lastFourDigits: "1234", logo: "assets/images/image2.png"),
    PaymentMethod(type: "Visa", lastFourDigits: "5678", logo: "assets/images/visa.png"),
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
