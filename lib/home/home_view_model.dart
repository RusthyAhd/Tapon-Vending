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
  
  void fetchProducts() {
    _products = [
      ProductModel(
        name: "Doritos Nacho Cheese",
        imageUrl: "assets/images/image.png",
        price: 6.99,
        oldPrice: 10.00, onTap: () {  },
      ),
      ProductModel(
        name: "Lays Classic",
        imageUrl: "assets/images/image.png",
        price: 4.99,
        oldPrice: 7.00, onTap: () {  },
      ),
      ProductModel(
        name: "Cheetos Crunchy",
        imageUrl: "assets/images/image.png",
        price: 5.99,
        oldPrice: 8.00, onTap: () {  },
      ),
      ProductModel(
        name: "Pringles Original",
        imageUrl: "assets/images/image.png",
        price: 5.49,
        oldPrice: 7.50, onTap: () {  },
      ),
      ProductModel(
        name: "Ruffles Cheddar",
        imageUrl: "assets/images/image.png",
        price: 6.49,
        oldPrice: 9.00, onTap: () {  },
      ),
      ProductModel(
        name: "Takis Fuego",
        imageUrl: "assets/images/image.png",
        price: 7.49,
        oldPrice: 10.50, onTap: () {  },
      ),
      ProductModel(
        name: "Sun Chips Harvest",
        imageUrl: "assets/images/image.png",
        price: 5.99,
        oldPrice: 8.00, onTap: () {  },
      ),
      ProductModel(
        name: "Tostitos Scoops",
        imageUrl: "assets/images/image.png",
        price: 6.79,
        oldPrice: 9.20, onTap: () {  },
      ),
      ProductModel(
        name: "Fritos Original",
        imageUrl: "assets/images/image.png",
        price: 4.89,
        oldPrice: 6.50, onTap: () {  },
      ),
    ];

    notifyListeners();
  }
}
