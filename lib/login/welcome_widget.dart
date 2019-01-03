import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_login_form.dart';
import 'email_registration_widget.dart';

class WelcomeScreen extends StatelessWidget {
  final Function successCallback;

  const WelcomeScreen({Key key, @required this.successCallback})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new WelcomeForm(successCallback: successCallback),
    );
  }
}

class WelcomeForm extends StatefulWidget {
  final Function successCallback;

  const WelcomeForm({
    Key key,
    this.successCallback,
  }) : super(key: key);
  @override
  WelcomeFormState createState() {
    return new WelcomeFormState();
  }
}

class WelcomeFormState extends State<WelcomeForm> {
  bool _saving = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _handleGoogleLogin() async {
    setState(() {
      _saving = true;
    });
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );
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
    } finally {}
  }

  _handleEmailSignIn(String email, String password) async {
    setState(() {
      _saving = true;
    });
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        print("signed in " + user.displayName);
      } else {
        setState(() {
          _saving = false;
        });
      }
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Login hat nicht geklappt'),
        ),
      );
      setState(() {
        _saving = false;
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                              'Registrieren',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            FlatButton(
                              onPressed: _handleGoogleLogin,
                              child: Text('Mit Google-Konto registrieren'),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        EmailRegistrationScreen(
                                          successCallback:
                                              widget.successCallback,
                                        ),
                                  ),
                                );
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
