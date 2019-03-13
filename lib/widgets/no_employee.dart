import 'package:flutter/material.dart';

class NoEmployee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Sie sind noch an keinem Standort als Mitarbeiter registriert.\n\nBitte kontaktieren Sie Ihren Standort-Manager und lassen Sie sich als Mitarbeiter einladen.",
              textAlign: TextAlign.center,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
