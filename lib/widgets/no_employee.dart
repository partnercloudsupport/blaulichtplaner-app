import 'package:flutter/material.dart';

class NoEmployee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text("Sie sind noch an keinem Standort als Mitarbeiter registriert.")
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
