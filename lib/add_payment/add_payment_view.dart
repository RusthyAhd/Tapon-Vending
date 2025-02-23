import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_payment_view_model.dart';

class AddPaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPaymentViewModel(),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(13, 13, 13, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(13, 13, 13, 1),
          title: Center(
            child: Text("Add Payment Method",
                style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),
          ),
        ),
        body: Consumer<AddPaymentViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Enter your payment details',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),
                    Text('By continuing you agree to our Terms',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),

                    // Payment Options
                    Column(
                      
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                              viewModel.paymentMethods.length, (index) {
                            var method = viewModel.paymentMethods[index];
                            bool isSelected =
                                viewModel.selectedMethod == method;

                            return GestureDetector(
                              onTap: () => viewModel.selectMethod(index),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.asset(method.logo,
                                        width: 50, height: 50),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Cardholder Name
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Cardholder name",
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "John Henry",
                        hintStyle: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Card Number
                    Align( alignment: Alignment.centerLeft,child: Text("Card Number", style: TextStyle(color: Colors.white))),
                    TextField(
                      onChanged: viewModel.setCardNumber,
                      decoration: InputDecoration(
                        hintText: "**** **** **** 3947",
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
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
                              Text("Exp Month",
                                  style: TextStyle(color: Colors.white)),
                              DropdownButtonFormField(
                                dropdownColor: Colors.black,
                                value: viewModel.expiryMonth,
                                items: List.generate(12, (index) {
                                  return DropdownMenuItem(
                                    value: "${index + 1}".padLeft(2, '0'),
                                    child: Text("${index + 1}".padLeft(2, '0'),
                                        style: TextStyle(color: Colors.white)),
                                  );
                                }),
                                onChanged: (value) =>
                                    viewModel.setExpiryMonth(value as String),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[900],
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
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
                              Text("Exp Year",
                                  style: TextStyle(color: Colors.white)),
                              DropdownButtonFormField(
                                dropdownColor: Colors.black,
                                value: viewModel.expiryYear,
                                items: List.generate(10, (index) {
                                  return DropdownMenuItem(
                                    value: "${2024 + index}",
                                    child: Text("${2024 + index}",
                                        style: TextStyle(color: Colors.white)),
                                  );
                                }),
                                onChanged: (value) =>
                                    viewModel.setExpiryYear(value as String),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[900],
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // CVC
                    Text("CVC", textAlign: TextAlign.left,style: TextStyle(color: Colors.white)),
                    TextField(
                      onChanged: viewModel.setCVC,
                      decoration: InputDecoration(
                        hintText: "123",
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    // Save Card Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Save card",
                            style: TextStyle(color: Colors.white)),
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
                          if (viewModel.selectedMethod != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "${viewModel.selectedMethod!.type} card added successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select a payment method"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(129, 143, 249, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("Add now",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
