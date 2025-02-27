import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/custom/custom_text_field.dart';
import 'package:tapon_vending/forgot_password/forgot_password_view_model.dart';
import 'package:tapon_vending/login/login_view.dart';

class ForgotPasswordView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ForgotPasswordViewModel(), // Provide the ViewModel only for this screen
      child: Consumer<ForgotPasswordViewModel>(
          builder: (context, viewModel, child) {
        return Scaffold(
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                          child: Image.asset(
                        "assets/images/logo.png",
                        height: 200,
                        width: 200,
                      )),
                      SizedBox(height: 10),
                      Text('RESET PASSWORD',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Center(
                          child: Text(
                        'Enter your email to reset your password',
                        style:
                            TextStyle(color: Color.fromRGBO(217, 217, 217, 1)),
                      )),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email ',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                          hint: "Enter email", controller: emailController),
                      const SizedBox(height: 20),
                      Container(
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
                            minimumSize: Size(double.infinity, 40),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            viewModel.setEmail(emailController.text);
                            viewModel.resetPassword(context);
                          },
                          child: viewModel.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Submit",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Divider(color: Colors.white),
                      const SizedBox(height: 20),
                      Text('Remember credentials? ',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text('log in now',
                            style: TextStyle(
                                color: Color.fromRGBO(1, 181, 1, 1),
                                fontSize: 16,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
