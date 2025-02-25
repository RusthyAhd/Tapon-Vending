import 'package:flutter/material.dart';
import 'package:tapon_vending/home/product_model.dart';
import 'package:tapon_vending/Popup/confirmation_popup.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;

  const ProductTile({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ConfirmationPopup(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(product.imageUrl, height: 80, width: 80),
            SizedBox(height: 10),
            Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("\$${product.price.toStringAsFixed(2)}"),
            Text(
              "\$${product.oldPrice.toStringAsFixed(2)}",
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
