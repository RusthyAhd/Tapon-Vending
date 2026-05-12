import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/custom/custom_text_field.dart';
import 'package:tapon_vending/login/login_view.dart';
import 'package:tapon_vending/sign_up/signup_view_model.dart';
import 'package:tapon_vending/sign_up/terms_and_conditions_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController mobileController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    mobileController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

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
                        const SizedBox(height: 20),
                        const Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Enter your details to create new account',
                            style: TextStyle(
                                color: Color.fromRGBO(217, 217, 217, 1)),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Error Message Display
                        if (viewModel.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              border: Border.all(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    viewModel.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                          onChanged: (value) => viewModel.setName(value),
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
                          onChanged: (value) => viewModel.setMobile(value),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        const SizedBox(height: 5),
                        CustomTextField(
                          hint: "Enter email",
                          controller: emailController,
                          onChanged: (value) => viewModel.setEmail(value),
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
                          onChanged: (value) => viewModel.setPassword(value),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsAndConditionsView(),
                              ),
                            );
                            if (result == true) {
                              viewModel.toggleAgreeToTerms(true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: viewModel.agreeToTerms
                                    ? Color.fromRGBO(1, 181, 1, 1)
                                    : Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: viewModel.agreeToTerms
                                        ? Color.fromRGBO(1, 181, 1, 1)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: viewModel.agreeToTerms
                                          ? Color.fromRGBO(1, 181, 1, 1)
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: viewModel.agreeToTerms
                                      ? const Icon(Icons.check,
                                          color: Colors.black, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'I agree to the',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final result =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TermsAndConditionsView(),
                                            ),
                                          );
                                          if (result == true) {
                                            viewModel.toggleAgreeToTerms(true);
                                          }
                                        },
                                        child: const Text(
                                          'Terms and Conditions',
                                          style: TextStyle(
                                            color: Color.fromRGBO(1, 181, 1, 1),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 55,
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
                              minimumSize: const Size(double.infinity, 40),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: viewModel.isLoading
                                ? null
                                : () {
                                    viewModel
                                        .setName(nameController.text.trim());
                                    viewModel.setMobile(
                                        mobileController.text.trim());
                                    viewModel
                                        .setEmail(emailController.text.trim());
                                    viewModel
                                        .setPassword(passwordController.text);

                                    viewModel.signup(context);
                                  },
                            child: viewModel.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Already have an account? ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text('log in now',
                              style: TextStyle(
                                color: Color.fromRGBO(1, 181, 1, 1),
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
