import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

bool isNotEmpty(String value) {
  return value != null && value.isNotEmpty;
}

Future<void> showErrorDialog(BuildContext context, Exception e) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Fehler"),
        content: Text("Fehler: $e"),
        actions: <Widget>[
          FlatButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}
