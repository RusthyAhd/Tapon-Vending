import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/payment_method/payment_method_model.dart';
import 'payment_view_model.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PAYMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("payment with securely", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        body: Consumer<PaymentViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...viewModel.methods.map((method) {
                    return Card(
                      color: Colors.black,
                      child: ListTile(
                        leading: Image.asset(method.logo, width: 40),
                        title: Text(method.type, style: TextStyle(color: Colors.white)),
                        subtitle: Text("**** ${method.lastFourDigits}", style: TextStyle(color: Colors.white54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Change", style: TextStyle(color: Colors.green)),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                viewModel.removePaymentMethod(viewModel.methods.indexOf(method));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      viewModel.addPaymentMethod(PaymentMethod(
                        type: "Visa Card",
                        lastFourDigits: "5678",
                        logo: "assets/visa.png",
                      ));
                    },
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text("Add new method", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.white,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "PAYMENTS"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
        ),
      ),
    );
  }
}
