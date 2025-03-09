import 'package:flutter/material.dart';
import 'package:tapon_vending/connect_to_machine.dart';

class ConnectToMachine extends StatelessWidget {
  const ConnectToMachine({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConnectToMachinePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(5, 248, 175, 1),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
                child: Text("Connect to Machine"),
              ),
    );
  }
}