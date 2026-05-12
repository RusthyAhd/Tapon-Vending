import 'package:flutter/material.dart';
import 'package:tapon_vending/custom/confirmation_dialog.dart';
import 'package:tapon_vending/home/product_model.dart';
import 'package:tapon_vending/bluetooth_service.dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductTile extends StatefulWidget {
  final ProductModel product;

  const ProductTile({super.key, required this.product});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTapUp: (_) => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 243, 248, 240),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromRGBO(0, 255, 204, 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 255, 204, 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image section
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: (product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty)
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.asset(
                                'assets/images/image.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                      ),
                    ),
                    // Details section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rs. ${product.priceBefore.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.black54,
                                  decorationThickness: 1.5,
                                  color: Colors.redAccent,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:   Color.fromRGBO(0, 255, 204, 0.7).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color.fromRGBO(0, 255, 204, 0.2),
                                  ),
                                ),
                                child: Text(
                                  'Rs. ${product.priceAfter.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(1, 181, 1, 1),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Cart Icon - Positioned at top center, overlapping image
                Positioned(
                  top: 88,
                  left: 110,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(0, 255, 204, 0.7),
                            Color.fromRGBO(1, 135, 95, 1),
                            
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:const Color.fromRGBO(0, 255, 204, 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> handlePurchase(
      BuildContext context, ProductModel product) async {
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
        print(
            '✨ SUCCESS DIALOG DISPLAYED - Vending machine should now dispense product');
        return AlertDialog(
          title: Text("Success"),
          content: Text("Your purchase was successful! Product dispensing..."),
          actions: [
            TextButton(
              onPressed: () {
                print('📍 User closed success dialog\n');
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
