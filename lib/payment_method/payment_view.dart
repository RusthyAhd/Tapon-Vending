import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/add_payment/add_payment_view.dart';
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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => EditProfilePage()));
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
              top: 20,
              left: MediaQuery.of(context).size.width / 2,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "PAYMENT",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold,fontSize: 25),
                      ),
                    ),
                    Text(
                      "payment with securely",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
           
            // Payment Methods List
            Positioned.fill(
                top: 80, 
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
                              leading: Image.asset(method.logo, width: 40,fit: BoxFit.contain,),
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
                                    icon: Icon(Icons.delete, color: Colors.white),
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
                           Navigator.push(context, MaterialPageRoute(builder: (context) => AddPaymentPage()));
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
         bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Color.fromRGBO(1, 181, 1, 1),
          unselectedItemColor: Colors.white,
           currentIndex: _selectedIndex,
           onTap: _onItemTapped,
          items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "PAYMENT"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
        
        ),
      ),
    );
  }
}
