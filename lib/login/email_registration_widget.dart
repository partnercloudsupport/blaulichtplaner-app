// TODO await user.sendEmailVerification();
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_form.dart';

class EmailRegistrationScreen extends StatelessWidget {
  final FirebaseUser user;
  final Function successCallback;
  EmailRegistrationScreen({Key key, this.user, this.successCallback})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrieren")),
      body: Stepper(
        steps: <Step>[
          Step(
            title: Text('E-Mail und Passwort'),
            subtitle: Text('Bla bla'),
            content: TextField(
              decoration: InputDecoration(hintText: 'Textfeld'),
            ),
          ),
          Step(
              title: Text('Persönliche Daten'),
              subtitle: Text('Kontrollieren Sie Ihre Angaben!'),
              content: RegistrationForm()),
        ],
      ),
    );
  }
}
