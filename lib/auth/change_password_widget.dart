import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChangePasswordWidget extends StatefulWidget {
  final FirebaseUser user;

  const ChangePasswordWidget({Key key, @required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChangePasswordState();
  }
}

class ChangePasswordState extends State<ChangePasswordWidget> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  bool _passwordChangePossible = false;
  bool _obscureText = true;
  bool _changingPassword = false;

  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword1 = TextEditingController();
  TextEditingController newPassword2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPasswordProvider();
  }

  void _checkPasswordProvider() async {
    setState(() {
      _loading = true;
    });
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      for (UserInfo userInfo in user.providerData) {
        if (userInfo.providerId == "password") {
          _passwordChangePossible = true;
        }
      }
    }
    setState(() {
      _loading = false;
    });
  }

  String _minLengthPasswordValidator(value) {
    if (value != null && value.length < 8) {
      return "Bitte geben Sie mindestens 8 Zeichen ein";
    } else {
      return null;
    }
  }

  String _validateNewPassword(value) {
    String minLength = _minLengthPasswordValidator(value);
    if (minLength == null) {
      if (newPassword1.text != newPassword2.text) {
        return "Passwörter stimmen nicht überein";
      } else {
        return null;
      }
    } else {
      return minLength;
    }
  }

  Future<bool> _changePassword(BuildContext context) async {
    String email = widget.user.email;
    String password = currentPassword.text;
    String newPassword = newPassword1.text;

    try {
      AuthCredential credential = EmailAuthProvider.getCredential(
        email: email,
        password: password,
      );
      await widget.user.reauthenticateWithCredential(credential);
      await widget.user.updatePassword(newPassword);
      return showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text("Passwort geändert"),
              content: Text("Ihr Passwort wurde erfolgreich geändert."),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text("Ok"))
              ],
            );
          });
    } catch (e) {
      return showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text("Fehler"),
              content:
                  Text("Ihr Passwort konnte nicht geändert werden.\n\n[$e]"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, false);
                    },
                    child: Text("Ok"))
              ],
            );
          });
    } finally {
      setState(() {
        _changingPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Passwort ändern")),
      body: LoaderBodyWidget(
        loading: _loading,
        empty: !_passwordChangePossible,
        fallbackText:
            "Sie haben sich ohne Passwort angemeldet. Eine Änderung des Passworts ist daher nicht möglich.",
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("Account:"),
                subtitle: Text(widget.user.email),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: currentPassword,
                        decoration: InputDecoration(
                            labelText: "Ihr bisheriges Passwort"),
                        obscureText: _obscureText,
                        validator: _minLengthPasswordValidator,
                      ),
                      TextFormField(
                        controller: newPassword1,
                        decoration:
                            InputDecoration(labelText: "Neues Passwort"),
                        obscureText: _obscureText,
                        validator: _validateNewPassword,
                      ),
                      TextFormField(
                        controller: newPassword2,
                        decoration: InputDecoration(
                            labelText: "Neues Passwort wiederholen"),
                        obscureText: _obscureText,
                        validator: _validateNewPassword,
                      ),
                      CheckboxListTile(
                          title: Text("Passwortzeichen anzeigen"),
                          value: !_obscureText,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _obscureText = !value;
                            });
                          }),
                      LoaderWidget(
                        loading: _changingPassword,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            RaisedButton(
                              color: Colors.blue,
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    _changingPassword = true;
                                  });
                                  bool success = await _changePassword(context);
                                  if (success) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              child: Text(
                                'Passwort ändern',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
