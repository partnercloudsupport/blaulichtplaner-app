import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/widgets/project_id.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_login_form.dart';

typedef LoginCallback = Function(FirebaseUser user);

class WelcomeScreen extends StatelessWidget {
  final LoginCallback loginCallback;
  final Function registerWithMail;
  final Function registerWithGoogle;

  const WelcomeScreen(
      {Key key,
      @required this.loginCallback,
      @required this.registerWithMail,
      @required this.registerWithGoogle})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints.expand(),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/blp-logo.png",
                              width: 64,
                            ),
                          ),
                        ),
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
                            'Bitte loggen Sie sich ein.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        LoginForm(
                          loginCallback: loginCallback,
                          loginWithGoogle: registerWithGoogle != null,
                        ),
                        RegisterButtons(
                          registerWithGoogle: registerWithGoogle,
                          registerWithMail: registerWithMail,
                        ),
                        Divider(),
                        Center(child: ProjectIdText())
                      ],
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterButtons extends StatelessWidget {
  final Function registerWithMail;
  final Function registerWithGoogle;

  const RegisterButtons(
      {Key key,
      @required this.registerWithMail,
      @required this.registerWithGoogle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (registerWithGoogle != null || registerWithMail != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Registrieren',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Visibility(
            visible: registerWithGoogle != null,
            child: FlatButton(
              onPressed: registerWithGoogle,
              child: Text('Mit Google-Konto registrieren'),
            ),
          ),
          FlatButton(
            onPressed: registerWithMail,
            child: Text('Mit E-Mail und Passwort registerieren'),
          )
        ],
      );
    } else {
      return Text("");
    }
  }
}

class LoginForm extends StatefulWidget {
  final LoginCallback loginCallback;
  final bool loginWithGoogle;

  const LoginForm({
    Key key,
    @required this.loginCallback,
    @required this.loginWithGoogle,
  }) : super(key: key);
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  bool _loginInProgress = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _handleGoogleLogin() async {
    try {
      setState(() {
        _loginInProgress = true;
      });
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        FirebaseUser user =
            await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ));
        if (user != null) {
          final Firestore _firestore = FirestoreImpl.instance;
          DocumentSnapshot userSnapshot =
              await _firestore.collection("users").document(user.uid).document;
          if (userSnapshot.exists) {
            print("signed in " + user.displayName);
            widget.loginCallback(user);
          } else {
            user.delete();
            Scaffold.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 5),
                content: Text('Der Benutzer ist noch nicht registriert'),
              ),
            );
          }
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loginInProgress = false;
      });
    }
  }

  _handleEmailSignIn(String email, String password) async {
    try {
      setState(() {
        _loginInProgress = true;
      });
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user.isEmailVerified) {
        widget.loginCallback(user);
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 30),
            content: Text(
                'Ihre E-Mail Adresse ist noch nicht bestätigt. Bitte überprüfen Sie Ihr E-Mail Postfach'),
            action: SnackBarAction(
              label: "E-Mail erneut senden",
              onPressed: () {
                user.sendEmailVerification();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print("error logging in: $e");
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Fehler beim Login. Bitte überprüfen Sie Ihre Daten und die Internetverbindung.'),
        ),
      );
    } finally {
      setState(() {
        _loginInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Einloggen',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        EmailLoginForm(
          emailLogin: _handleEmailSignIn,
          loginInProgress: _loginInProgress,
        ),
        Visibility(
          visible: widget.loginWithGoogle,
          child: FlatButton(
            onPressed: _handleGoogleLogin,
            child: Text("Mit Google-Konto anmelden"),
          ),
        ),
      ],
    );
  }
}
