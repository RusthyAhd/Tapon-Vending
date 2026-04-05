import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/bluetooth_service.dart.dart';
import 'package:tapon_vending/connect_to_machine.dart';
import 'package:tapon_vending/custom/custom_bottom_nav_bar.dart';
import 'package:tapon_vending/custom/product_tile.dart';
import 'package:tapon_vending/home/home_view_model.dart';
import 'package:tapon_vending/payment_method/payment_view.dart';
import 'package:tapon_vending/profile/profile_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PaymentPage()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => EditProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
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
              top: 100,
              left: 20,
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  return Text(
                    "Hi, ${viewModel.userName.isNotEmpty ? viewModel.userName : 'Guest'}!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              bottom: 0, // Ensure it doesn't overflow
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.products.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Compute number of columns based on available width
                        int crossAxis = (constraints.maxWidth ~/ 180);
                        if (crossAxis < 2) crossAxis = 2;
                        if (crossAxis > 4)
                          crossAxis = 4; // limit for large screens

                        // Estimate child height to produce a reasonable aspect ratio
                        final tileWidth = constraints.maxWidth / crossAxis;
                        final estimatedTileHeight =
                            220; // adjust if your ProductTile height changes
                        final childAspectRatio =
                            tileWidth / estimatedTileHeight;

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxis,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: viewModel.products.length,
                          itemBuilder: (context, index) {
                            return ProductTile(
                                product: viewModel.products[index]);
                          },
                        );
                      },
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
