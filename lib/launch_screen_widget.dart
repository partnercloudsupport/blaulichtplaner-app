import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/blaulichtplaner_app.dart';
import 'package:blaulichtplaner_app/login/email_registration_widget.dart';
import 'package:blaulichtplaner_app/login/registration_service.dart';
import 'package:blaulichtplaner_app/login/welcome_widget.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LaunchScreen extends StatefulWidget {
  LaunchScreen({Key key}) : super(key: key);

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  final UserManager _userManager = UserManager.instance;
  bool _initialized = false;
  bool _loginInProgress = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  BlpUser _user;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() async {
    FirebaseUser currentUser = await _auth.currentUser();
    if (currentUser != null) {
      if (currentUser.isEmailVerified) {
        _user = await _userManager.initUser(currentUser);
      } else {
        _auth.signOut();
      }
    }
    setState(() {
      _initialized = true;
    });
  }

  void _logout() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      // TODO check if providerId should be google. the framework returns "firebase" atm
      if (user.providerId == "firebase") {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email'],
        );
        try {
          await googleSignIn.disconnect();
        } on PlatformException catch (e) {
          print(
              e); // open issue here https://github.com/flutter/flutter/issues/26705
        }
      }
    }
    await _auth.signOut();
    _userManager.logout();
    setState(() {
      _user = null;
    });
  }

  _login(FirebaseUser user) async {
    setState(() {
      _loginInProgress = true;
    });
    _user = await _userManager.initUser(user);
    setState(() {
      _loginInProgress = false;
    });
  }

  _registerWithMail() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => RegistrationScreen(),
        ));
  }

  _registerWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );
    GoogleSignInAccount account = await googleSignIn.signIn();
    if (account != null) {
      GoogleSignInAuthentication googleAuth = await account.authentication;
      FirebaseUser newUser =
          await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ));
      RegistrationResult result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RegistrationScreen(
                  user: newUser,
                  photoUrl: account.photoUrl,
                ),
          ));
      if (result != null) {
        _login(result.user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderBodyWidget(
      loading: !_initialized || _loginInProgress,
      child: BlaulichtplanerApp(
        logoutCallback: _logout,
      ),
      empty: _user == null,
      fallbackWidget: WelcomeScreen(
        loginCallback: _login,
        registerWithGoogle: _registerWithGoogle,
        registerWithMail: _registerWithMail,
      ),
    );
  }
}
