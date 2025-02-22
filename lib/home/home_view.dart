import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/custom/product_tile.dart';
import 'package:tapon_vending/home/home_view_model.dart';
import 'package:tapon_vending/payment_method/payment_view.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
        // Green background decoration
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
        // Greeting Text
        Positioned(
          top: 20,
          left: 20,
          child: Text(
            "Hi, Rishaf!",
            style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Product Grid
        Positioned.fill(
          top: 50, // Adjust so text is not overlapped
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
              ),
              itemCount: viewModel.products.length,
              itemBuilder: (context, index) {
            return ProductTile(product: viewModel.products[index]);
              },
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
          items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "PAYMENT"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
          onTap: (index) {
        switch (index) {
          case 0:
            // Navigate to Home
             Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            break;
            break;
          case 1:
            // Navigate to Payment
            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
            break;
          case 2:
            // Navigate to Profile
            Navigator.pushNamed(context, '/profile');
            break;
        }
          },
        ),
      ),
     
    );
  }
}
