import 'package:flutter/material.dart';
import 'package:tapon_vending/home/product_model.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;

  ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade700.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(product.imageUrl, height: 70,width:100),
          SizedBox(height: 10),
          Text(product.name, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
          SizedBox(height: 5),
          Text("\$${product.oldPrice}", style: TextStyle(color: Colors.white, fontSize: 10, decoration: TextDecoration.lineThrough)),
          Text("\$${product.price}", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
