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
      body: WelcomeForm(successCallback: successCallback),
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
    return WelcomeFormState();
  }
}

class WelcomeFormState extends State<WelcomeForm> {
  bool _saving = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _handleGoogleLogin() async {
    try {
      setState(() {
        _saving = true;
      });
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
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  _handleEmailSignIn(String email, String password) async {
    try {
      setState(() {
        _saving = true;
      });
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Fehler beim Login. Bitte überprüfen Sie Ihre Daten und die Internetverbindung.'),
        ),
      );
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LoaderWidget(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Willkommen beim Blaulichtplaner',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Bitte loggen Sie sich ein oder erstellen Sie einen Benutzer.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Einloggen',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                        EmailLoginForm(emailLogin: _handleEmailSignIn),
                        FlatButton(
                          onPressed: _handleGoogleLogin,
                          child: Text("Mit Google-Konto anmelden"),
                        ),
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
                                      successCallback: widget.successCallback,
                                    ),
                              ),
                            );
                          },
                          child: Text('Mit E-Mail und Passwort registerieren'),
                        )
                      ],
                    ),
                  ),
                  loading: _saving,
                  padding: EdgeInsets.only(top: 16.0),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),
      ),
    );
  }
}