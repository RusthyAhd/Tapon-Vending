import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({super.key, required this.hint, required this.controller, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white), // Set the text color to white
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54), // Optional: Set hint text color to a lighter white
        filled: true,
        fillColor: Color.fromRGBO(22, 22, 22, 1).withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}
