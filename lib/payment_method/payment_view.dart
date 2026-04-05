import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/add_payment/add_payment_view.dart';
import 'package:tapon_vending/custom/custom_bottom_nav_bar.dart';
import 'package:tapon_vending/home/home_view.dart';
import 'package:tapon_vending/profile/profile_view.dart';
import 'payment_view_model.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedIndex = 1; // Ensure Payment is selected

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        break; // Already on Payment
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => EditProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background Decorations
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 240,
                height: 210,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(5, 248, 175, 0.3),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(130),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 220,
                height: 190,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(1, 192, 135, 0.52),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(130),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: (MediaQuery.of(context).size.width - 150) / 2,
              child: Center(
                // Wrap the Column with Center
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "PAYMENT",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                    ),
                    Text(
                      "payment with securely",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 50), // Added SizedBox for spacing
                  ],
                ),
              ),
            ),

            // Balance Card
            Positioned.fill(
              top: 150, // Adjusted top position to account for the new SizedBox
              child: Align(
                alignment: Alignment.topCenter,
                child: BalanceCard(),
              ),
            ),

            // SizedBox for spacing
            Positioned.fill(
              top: 350,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(height: 20),
              ),
            ),

            // Payment Methods List
            Positioned.fill(
              top: 350,
              child: Consumer<PaymentViewModel>(
                builder: (context, viewModel, child) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...viewModel.methods.map((method) {
                          return Card(
                            color: Colors.black.withOpacity(0.5),
                            child: ListTile(
                              leading: Image.asset(
                                method.logo,
                                width: 40,
                                fit: BoxFit.contain,
                              ),
                              title: Text(method.type,
                                  style: TextStyle(color: Colors.white)),
                              subtitle: Text("**** ${method.lastFourDigits}",
                                  style: TextStyle(color: Colors.white54)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Change",
                                      style: TextStyle(color: Colors.green)),
                                  IconButton(
                                    icon:
                                        Icon(Icons.delete, color: Colors.white),
                                    onPressed: () {
                                      viewModel.removePaymentMethod(
                                          viewModel.methods.indexOf(method));
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddPaymentPage()));
                          },
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text("Add new method",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: 320,
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Balance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    onPressed: () => viewModel.fetchBalance(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              viewModel.isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.green))
                  : Text(
                      "${viewModel.balance.toStringAsFixed(2)} LkR",
                      style: TextStyle(
                        color: viewModel.balance < 0 ? Colors.redAccent : Colors.greenAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(height: 10),
              const Text(
                "Please top up your balance to keep your account active.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
