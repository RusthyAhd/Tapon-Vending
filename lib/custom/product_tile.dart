import 'package:flutter/material.dart';
import 'package:tapon_vending/custom/confirmation_dialog.dart';

import 'package:tapon_vending/home/product_model.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;

  ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showConfirmationDialog(context, product.name, () {
          // Handle the confirmation action here
          print('Order confirmed for ${product.name}');
        });
      },
      child: Card(
        child: Column(
          children: [
            Image.asset(
              product.imageUrl,
              height: 100, // Adjust the height to make the image smaller
              width: 80, // Adjust the width to make the image smaller
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10), // Add some spacing between the image and text
            Text(product.name),
             SizedBox(height: 10),
            Text('\Rs. ${product.price.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
