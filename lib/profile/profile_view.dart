import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/change_password/change_password_view.dart';
import 'package:tapon_vending/custom/custom_bottom_nav_bar.dart';
import 'package:tapon_vending/home/home_view.dart';
import 'package:tapon_vending/payment_method/payment_view.dart';
import 'package:tapon_vending/profile/profile_view_model.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int _selectedIndex = 2;

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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PaymentPage()));
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(),
      child: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: viewModel.isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.green))
                : Stack(
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'EDIT PROFILE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            // Name Field
                            Text("Name", style: TextStyle(color: Colors.white)),
                            TextField(
                              controller: viewModel.nameController,
                              decoration: _inputDecoration("Enter your name"),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 10),

                            // Email Field
                            Text("Email",
                                style: TextStyle(color: Colors.white)),
                            TextField(
                              controller: viewModel.emailController,
                              decoration: _inputDecoration("Enter your email"),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 10),

                            // Mobile Field
                            Text("Mobile",
                                style: TextStyle(color: Colors.white)),
                            TextField(
                              controller: viewModel.mobileController,
                              decoration: _inputDecoration("Enter your number"),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 10),

                            // Password Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Password",
                                    style: TextStyle(color: Colors.white)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChangePasswordView())); // Implement Change Password logic
                                  },
                                  child: Text("Change",
                                      style: TextStyle(color: Colors.green)),
                                ),
                              ],
                            ),

                            // Save Button
                            Spacer(),
                            Center(
                              child: Container(
                                height: 40, // Added width to the button
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromRGBO(1, 181, 1, 1),
                                      Color.fromRGBO(1, 135, 95, 1)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () {
                                    viewModel.updateUserProfile();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Your profile details updated")),
                                    );
                                  },
                                  child: Text("Save",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
