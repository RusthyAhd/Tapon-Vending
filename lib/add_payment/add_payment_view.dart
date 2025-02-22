import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/add_payment/add_payment_view_model.dart';

class AddPaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPaymentViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(
            child: Text("Add Payment Method", style: TextStyle(color: Colors.white)),
          ),
        ),
        body: Consumer<AddPaymentViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(viewModel.paymentMethods.length, (index) {
                      var method = viewModel.paymentMethods[index];
                      return GestureDetector(
                        onTap: () => viewModel.selectMethod(index),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(method.logo, width: 50, height: 50),
                            if (method.isSelected)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Cardholder Name
                  Text("Cardholder name", style: TextStyle(color: Colors.white)),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "John Henry",
                      hintStyle: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Card Number
                  Text("Card Number", style: TextStyle(color: Colors.white)),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "**** **** **** 3947",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),

                  // Expiration Date
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Exp Month", style: TextStyle(color: Colors.white)),
                            DropdownButtonFormField(
                              dropdownColor: Colors.black,
                              value: "12",
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: "${index + 1}",
                                  child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                                );
                              }),
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[900],
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Exp Year", style: TextStyle(color: Colors.white)),
                            DropdownButtonFormField(
                              dropdownColor: Colors.black,
                              value: "2024",
                              items: List.generate(10, (index) {
                                return DropdownMenuItem(
                                  value: "${2024 + index}",
                                  child: Text("${2024 + index}", style: TextStyle(color: Colors.white)),
                                );
                              }),
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[900],
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // CVC
                  Text("CVC", style: TextStyle(color: Colors.white)),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "123",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  // Save Card Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Save card", style: TextStyle(color: Colors.white)),
                      Switch(value: false, onChanged: (value) {}),
                    ],
                  ),

                  // Add Now Button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add functionality for adding a payment method
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Add now", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
