import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/home/homeviwe.dart';
import 'package:tapon_vending/login/login_view.dart';
import 'package:tapon_vending/login/login_view_model.dart';
import 'package:tapon_vending/new.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      //home: LiveRadioScreen(),
    );
  }
}


