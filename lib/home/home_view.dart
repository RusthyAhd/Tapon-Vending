import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            Positioned.fill(
              top: 120,
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.products.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.6, // Adjusted aspect ratio
                      ),
                      itemCount: viewModel.products.length,
                      itemBuilder: (context, index) {
                        final product = viewModel.products[index];
                        // return Card(
                        //   color: Colors.white,
                        //   shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(10)),
                        //   margin: EdgeInsets.symmetric(vertical: 5),
                        return Padding(
                          padding: const EdgeInsets.all(
                              4.0), 
                          // child: ListTile(
                          //   title: Text(
                          //     product.name,
                          //     style: TextStyle(fontWeight: FontWeight.bold),
                          //   ),
                          //   subtitle: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //           "Price Before Discount: \$${product.priceBefore}"),
                          //       Text(
                          //           "Price After Discount: \$${product.priceAfter}"),
                          //     ],
                          //   ),
                          // ),
                         child:
                              ProductTile(product: viewModel.products[index]),  
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
