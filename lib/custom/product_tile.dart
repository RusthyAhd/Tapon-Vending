import 'package:flutter/material.dart';
import 'package:tapon_vending/custom/confirmation_dialog.dart';
import 'package:tapon_vending/home/product_model.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;

  ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Before: Rs. ${product.priceBefore.toStringAsFixed(2)}',
              style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red),
            ),
            Text(
              'Price After: Rs. ${product.priceAfter.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
        trailing: Icon(Icons.shopping_cart, color: Colors.black54),
        onTap: () {
          showConfirmationDialog(context, product.name, () {
            print('Order confirmed for ${product.name}');
          });
        },
      ),
    );
  }
}
