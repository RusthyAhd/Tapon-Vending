import 'package:flutter/material.dart';
import 'package:tapon_vending/home/product_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  HomeViewModel() {
    fetchProducts();
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
