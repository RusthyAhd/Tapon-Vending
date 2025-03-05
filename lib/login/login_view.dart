import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/custom/custom_text_field.dart';
import 'package:tapon_vending/forgot_password/forgot_password_view.dart';
import 'package:tapon_vending/login/login_view_model.dart';
import 'package:tapon_vending/services/google_sign_in_service.dart';
import 'package:tapon_vending/sign_up/signup_view.dart';

class LoginPage extends StatelessWidget {
  //  void _handleGoogleSignIn(BuildContext context) async {
  //   User? user = await GoogleSignInService().signInWithGoogle();
  //   if (user != null) {
  //     // Navigate to home page or profile
  //     Navigator.pushReplacementNamed(context, '/home');
  //   } else {
  //     // Handle error or display message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Google Sign-In Failed")),
  //     );
  //   }
  // }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

 
  
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Consumer<LoginViewModel>(builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: constraints.maxWidth * 0.6,
                      height: constraints.maxHeight * 0.3,
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
                      width: constraints.maxWidth * 0.55,
                      height: constraints.maxHeight * 0.27,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(1, 192, 135, 0.52),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(130),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Center(
                            child: Image.asset(
                              "assets/images/logo.png",
                              height: constraints.maxHeight * 0.2,
                              width: constraints.maxWidth * 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter email or mobile number',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomTextField(
                            hint: "Enter your email or mobile number",
                            controller: emailController,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter password',
                              textAlign: TextAlign.start,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomTextField(
                            hint: "**************",
                            controller: passwordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Switch(
                                    value: viewModel.rememberMe,
                                    onChanged: viewModel.toggleRememberMe,
                                    activeColor: Color.fromRGBO(1, 181, 1, 1),
                                  ),
                                  const Text(
                                    "Remember Me",
                                    style: TextStyle(color: Color.fromRGBO(215, 215, 215, 0.6)),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgotPasswordView(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(1, 181, 1, 1),
                                  Color.fromRGBO(1, 135, 95, 1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                viewModel.setEmailOrMobile(emailController.text);
                                viewModel.setPassword(passwordController.text);
                                viewModel.login(context);
                              },
                              child: viewModel.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.white),
                          const SizedBox(height: 10),
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Color.fromRGBO(215, 215, 215, 0.6)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupView(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign In Now",
                              style: TextStyle(color: Color.fromRGBO(1, 181, 1, 1)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text("Or", style: TextStyle(color: Colors.white)),
                              ),
                              Expanded(child: Divider(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 40),
                              backgroundColor: Color.fromRGBO(22, 22, 22, 1).withOpacity(0.9),
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color.fromRGBO(43, 45, 51, 1)),
                            ),
                            icon: Image.asset("assets/images/google.png", height: 20),
                            label: const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text("Sign in with Google"),
                            ),
                             onPressed: () {}
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
