import 'dart:async';

import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  bool _saving = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  Future _handleSignIn() async {
    setState(() {
      _saving = true;
    });
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      FirebaseUser user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("signed in " + user.displayName);
    } else {
      setState(() {
        _saving = false;
      });
    }
  }

  _signInEmail(String email, String password) async {
    FirebaseUser emailUser = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (emailUser != null) {
      print("signed in " + emailUser.displayName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              Text("Willkommen beim Blaulichtplaner"),
              LoaderWidget(
                child: FlatButton(
                  onPressed: _handleSignIn,
                  child: Text("Login mit Google"),
                ),
                loading: _saving,
                padding: EdgeInsets.only(top: 16.0),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}
