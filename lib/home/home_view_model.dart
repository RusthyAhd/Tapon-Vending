import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tapon_vending/home/product_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<ProductModel> _products = [];
  String _userName = '';
  String get userName => _userName; // Provide a getter for user name

  List<ProductModel> get products => _products;

  HomeViewModel() {
    fetchProducts();
    fetchUserName();
  }
   // Fetch user name from Firebase Firestore
  void fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _userName = userDoc['name']; // Assuming 'name' is the field in Firestore
        notifyListeners();
      }
    }
  }
   Future<void> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('items').orderBy('timestamp', descending: true).get();

      _products = querySnapshot.docs.map((doc) {
        return ProductModel(
          id: doc.id,
          name: doc['name'],
          priceBefore: doc['priceBefore'],
          priceAfter: doc['priceAfter'],
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print("Error fetching products: $e");
    }
  }
}