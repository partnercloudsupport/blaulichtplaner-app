import 'package:blaulichtplaner_app/auth/reset_password_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbauth;

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final fbauth.FirebaseAuth _auth = fbauth.FirebaseAuth.instance;
  bool loading = false;
  String _statusMessage = "";

  void _resetPassword(String email) async {
    try {
      setState(() {
        _statusMessage = "";
        loading = true;
      });
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        _statusMessage =
            "Wir haben Ihnen eine E-Mail geschickt mit der Sie ein neues Passwort festlegen können. Bitte prüfen Sie ihr Postfach.";
      });
    } catch (e) {
      print(e);
      _statusMessage = e.toString();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password zurücksetzen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                  "Bitte geben Sie hier Ihre E-Mail Adresse ein. Wir schicken Ihnen eine Mail mit einem Code, den Sie bitte in das untere Feld eingeben. Dort können Sie dann ein neues Passwort festlegen."),
              ResetPasswordForm(
                loading: loading,
                onReset: _resetPassword,
              ),
              Visibility(
                  visible: _statusMessage.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(_statusMessage),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
