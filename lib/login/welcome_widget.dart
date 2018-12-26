import 'dart:async';

import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_login_form.dart';
import 'email_registration_widget.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WelcomeScreenState();
  }
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool _saving = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  _handleGoogleLogin() async {
    setState(() {
      _saving = true;
    });
    try {
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
    } catch (e) {
      print(e);
      setState(() {
        _saving = false;
      });
    }
  }

  _handleEmailRegistration(String email, String password) async {
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await user.sendEmailVerification();
  }

  _handleEmailSignIn(String email, String password) async {
    setState(() {
      _saving = true;
    });
    try {
      FirebaseUser emailUser = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (emailUser != null) {
        print("signed in " + emailUser.displayName);
      } else {
        setState(() {
          _saving = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Willkommen beim Blaulichtplaner',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Text(
                  'Bitte loggen Sie sich ein oder erstellen Sie einen Benutzer.'),
              LoaderWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Einloggen',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            EmailLoginForm(emailLogin: _handleEmailSignIn),
                            FlatButton(
                              onPressed: _handleGoogleLogin,
                              child: Text("Mit Google-Konto anmelden"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Einloggen',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            FlatButton(
                              onPressed: () {},
                              child: Text('Mit Google-Konto registrieren'),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            EmailRegistrationScreen()));
                              },
                              child:
                                  Text('Mit E-Mail und Passwort registerieren'),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
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
