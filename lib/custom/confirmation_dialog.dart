import 'package:flutter/material.dart';

Future<void> showConfirmationDialog(
    BuildContext context, String productName, VoidCallback onConfirm) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Order'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Do you want to confirm the order for $productName?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
