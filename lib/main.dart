import 'package:flutter/material.dart';
import 'package:tapon_vending/home/homeviwe.dart';
import 'package:tapon_vending/new.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: LiveRadioScreen(),
    );
  }
}


