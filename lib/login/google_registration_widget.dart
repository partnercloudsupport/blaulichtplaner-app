import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_form.dart';

class GoogleRegistrationScreen extends StatelessWidget {
  final FirebaseUser user;
  final Function successCallback;
  GoogleRegistrationScreen(
      {Key key, @required this.user, @required this.successCallback})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrieren")),
      body: Text('Hi'),
      /*TODO RegistrationForm(
        user: user,
        successCallback: successCallback,
      ),*/
    );
  }
}
