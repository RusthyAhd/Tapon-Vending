import 'package:flutter/material.dart';
import 'package:tapon_vending/custom/confirmation_dialog.dart';
import 'package:tapon_vending/home/product_model.dart';
import 'package:tapon_vending/bluetooth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;

  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original Price: Rs. ${product.priceBefore.toStringAsFixed(2)}',
              style: const TextStyle(
                  decoration: TextDecoration.lineThrough, color: Colors.red),
            ),
            Text(
              'Final Price: Rs. ${product.priceAfter.toStringAsFixed(2)}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
        trailing: const Icon(Icons.shopping_cart, color: Colors.black54),
        onTap: () {
          print('═' * 60);
          print('✓ PRODUCT SELECTED: ${product.name}');
          print('  • Slot ID: ${product.slotId}');
          print('  • Price: Rs. ${product.priceAfter.toStringAsFixed(2)}');
          print('═' * 60);
          
          showConfirmationDialog(context, product.name, () async {
            print('\n📋 PURCHASE CONFIRMATION DIALOG SHOWN');
            bool orderConfirmed = await handlePurchase(context, product);
            
            if (orderConfirmed) {
              print('\n✅ PURCHASE CONFIRMED');
              print('  • Product: ${product.name}');
              print('  • Slot ID: ${product.slotId}');
              print('  • Status: Processing Bluetooth transmission...\n');
              
              // Send slot ID to vending machine via Bluetooth
              // Using singleton instance - maintains connection across the app
              BluetoothService bluetoothService = BluetoothService();
              await bluetoothService.sendSlotId(product.slotId);
              
              showSuccessDialog(context);
            } else {
              print('\n❌ PURCHASE FAILED OR CANCELLED');
            }
          });
        },
      ),
    );
  }

  Future<bool> handlePurchase(BuildContext context, ProductModel product) async {
    try {
      print('💳 INITIATING PURCHASE PROCESS...');
      
      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;
      print('  • User ID: ${userId.substring(0, 8)}...');

      // Fetch the current balance from Firebase
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      double currentBalance = userDoc['balance']
          .toDouble(); // Assuming balance is stored as a double

      print('  • Current Balance: Rs. $currentBalance');
      print('  • Required Amount: Rs. ${product.priceAfter}');

      // Check if user has enough balance
      if (currentBalance >= product.priceAfter) {
        // Deduct the amount from the balance
        double newBalance = currentBalance - product.priceAfter;

        print('  • New Balance after deduction: Rs. $newBalance');
        print('  • Updating Firebase...');

        // Update the balance in Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'balance': newBalance,
        });

        print('✅ PURCHASE SUCCESSFUL - Balance Updated in Firebase');
        return true; // Purchase was successful
      } else {
        // Show an error if balance is insufficient
        print('❌ INSUFFICIENT BALANCE');
        print('  • Balance Needed: Rs. ${product.priceAfter - currentBalance}');
        showErrorDialog(context);
        return false; // Not enough balance
      }
    } catch (e) {
      print('❌ ERROR DURING PURCHASE: $e');
      return false; // Something went wrong
    }
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        print('✨ SUCCESS DIALOG DISPLAYED - Vending machine should now dispense product');
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Your purchase was successful! Product dispensing..."),
          actions: [
            TextButton(
              onPressed: () {
                print('📍 User closed success dialog\n');
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("OK"),
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
          title: const Text("Error"),
          content: const Text("Insufficient balance. Please top up your account."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
