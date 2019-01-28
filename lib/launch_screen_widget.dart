import 'package:blaulichtplaner_app/assignment/assignment_view.dart';
import 'package:blaulichtplaner_app/blaulichtplaner_app.dart';
import 'package:blaulichtplaner_app/invitation/invitation_view.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote_editor.dart';
import 'package:blaulichtplaner_app/location_votes/location_votes_view.dart';
import 'package:blaulichtplaner_app/login/email_registration_widget.dart';
import 'package:blaulichtplaner_app/login/google_registration_widget.dart';
import 'package:blaulichtplaner_app/login/registration_service.dart';
import 'package:blaulichtplaner_app/login/welcome_widget.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_view.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_overview.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/utils/utils.dart';
import 'package:blaulichtplaner_app/widgets/date_navigation.dart';
import 'package:blaulichtplaner_app/widgets/drawer.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LaunchScreen extends StatefulWidget {
  LaunchScreen({Key key}) : super(key: key);

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  bool _initialized = false;
  bool _loginInProgress = false;
  FirebaseUser _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final UserManager userManager = UserManager.get();

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() async {
    FirebaseUser currentUser = await _auth.currentUser();
    if (currentUser != null) {
      bool registered = await userManager.updateUserData(currentUser);
      setState(() {
        if (registered) {
          _user = currentUser;
        }
        _initialized = true;
      });
    } else {
      setState(() {
        _initialized = true;
      });
    }
  }

  void _logout() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      // TODO check if providerId should be google. the framework returns "firebase" atm
      if (user.providerId == "firebase") {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email'],
        );
        await googleSignIn.disconnect();
      }
    }
    await _auth.signOut();
    setState(() {
      _user = null;
    });
  }

  _login(FirebaseUser user) async {
    setState(() {
      _loginInProgress = true;
    });
    bool registered = await userManager.updateUserData(user);
    setState(() {
      _loginInProgress = false;
      if (registered) {
        _user = user;
      } else {
        // TODO show error or something
      }
    });
  }

  _registerWithMail() async {
    RegistrationResult result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => EmailRegistrationScreen(),
      ),
    );
    if (result != null) {
      // TODO show dialog about e-mail verification
    }
  }

  _registerWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );
    GoogleSignInAccount account = await googleSignIn.signIn();
    if (account != null) {
      GoogleSignInAuthentication googleAuth = await account.authentication;
      FirebaseUser newUser = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      RegistrationResult result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                GoogleRegistrationScreen(user: newUser),
          ));
      if (result != null) {
        setState(() {
          _user = result.user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderBodyWidget(
      loading: !_initialized || _loginInProgress,
      child: BlaulichtplanerApp(
        user: _user,
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
