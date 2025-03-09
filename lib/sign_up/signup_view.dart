import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/connect_to_machine.dart';
import 'package:tapon_vending/custom/custom_text_field.dart';
import 'package:tapon_vending/login/login_view.dart';
import 'package:tapon_vending/sign_up/signup_view_model.dart';

class SignupView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignupViewModel(),
      child: Consumer<SignupViewModel>(
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
              padding: const EdgeInsets.all(20),

              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'SIGN UP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                     Center(child: Text('Enter your details to create new account',style: TextStyle(color: Color.fromRGBO(217, 217, 217, 1)),)),
                  Center(child: Text('account',style: TextStyle(color: Color.fromRGBO(217, 217, 217, 1)),)),
                  const SizedBox(height: 30),
                   Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                    CustomTextField(
                      hint: "Enter name",
                      controller: nameController,
                    ),
                    const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Phone Number',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.start,
                    ),
                  ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      hint: "Enter mobile number",
                      controller: mobileController,
                    ),
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
                      hint: "Enter email",
                      controller: emailController,
                    ),
                    const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.start,
                    ),
                  ),
                   const SizedBox(height: 5),
                    CustomTextField(
                      hint: "******",
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Switch(
                          value: viewModel.agreeToTerms,
                          onChanged: viewModel.toggleAgreeToTerms,
                          activeColor: Color.fromRGBO(1, 181, 1, 1),
                        ),
                        Text(
                          "Agree to the terms and conditions",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                      const SizedBox(height: 10),
                    Container(
                      height: 55, // Added width to the button
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
                          final viewModel = Provider.of<SignupViewModel>(context,
                              listen: false);
                      
                          // Update ViewModel values before calling signup
                          viewModel.setName(nameController.text.trim());
                          viewModel.setMobile(mobileController.text.trim());
                          viewModel.setEmail(emailController.text.trim());
                          viewModel.setPassword(passwordController.text);
                      
                          viewModel.signup(context);
                        },
                        child: viewModel.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                      ),
                      
                    ),
                      
                    const SizedBox(height: 20),

                    Text('Already have an account? ',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  GestureDetector(
                    onTap: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
            ),],),
          );
        },
      ),
    );
  }
}
