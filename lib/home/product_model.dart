import 'dart:ui';

class ProductModel {
  final String name;
  final String imageUrl;
  final double price;
  final double oldPrice;
  final VoidCallback onTap;

  ProductModel({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.oldPrice,
    required this.onTap,
  });
}
