import 'package:flutter/material.dart';
import 'package:tapon_vending/custom/confirmation_dialog.dart';
import 'package:tapon_vending/home/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              style: TextStyle(
                  decoration: TextDecoration.lineThrough, color: Colors.red),
            ),
            Text(
              'Price After: Rs. ${product.priceAfter.toStringAsFixed(2)}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
        trailing: Icon(Icons.shopping_cart, color: Colors.black54),
        onTap: () {
          showConfirmationDialog(context, product.name, () async {
            bool orderConfirmed = await handlePurchase(context, product);
            if (orderConfirmed) {
              showSuccessDialog(context);
            }
          });
        },
      ),
    );
  }

  Future<bool> handlePurchase(BuildContext context, ProductModel product) async {
    try {
      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the current balance from Firebase
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      double currentBalance = userDoc['balance']
          .toDouble(); // Assuming balance is stored as a double

      // Check if user has enough balance
      if (currentBalance >= product.priceAfter) {
        // Deduct the amount from the balance
        double newBalance = currentBalance - product.priceAfter;

        // Update the balance in Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'balance': newBalance,
        });

        return true; // Purchase was successful
      } else {
        // Show an error if balance is insufficient
        showErrorDialog(context);
        return false; // Not enough balance
      }
    } catch (e) {
      print('Error during purchase: $e');
      return false; // Something went wrong
    }
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Your purchase was successful!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Insufficient balance. Please top up your account."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
