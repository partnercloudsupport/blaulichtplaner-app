import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nanoid/nanoid.dart';
import 'package:url_launcher/url_launcher.dart';

typedef void OnChanged(String value);

class RegistrationModel {
  String firstName = '';
  String lastName = '';
  String email = '';
  Timestamp privacyPolicyAccepted;
  Timestamp termsAccepted;
  String token;

  RegistrationModel.fromUser(FirebaseUser user) {
    if (user.displayName != null) {
      firstName = user.displayName.split(' ').first;
      lastName = user.displayName.split(' ').last;
    }
    email = user.email;
    token = nanoid(64);
  }

  Map<String, dynamic> createData() {
    Map<String, dynamic> data = {};
    data["firstName"] = firstName;
    data["lastName"] = lastName;
    data["email"] = email;
    data["privacyPolicyAccepted"] = privacyPolicyAccepted;
    data["termsAccepted"] = termsAccepted;
    data["token"] = token;
    return data;
  }
}

class TermsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const TermsForm({Key key, this.formKey}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TermsFormState();
  }
}

class _TermsFormState extends State<TermsForm> {
  bool _eula = false;
  bool _privacy = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          FormField(
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                title: Text('AGBs akzeptieren'),
                value: _eula,
                onChanged: (value) {
                  setState(() {
                    _eula = value;
                  });
                },
                activeColor: Colors.blue,
                controlAffinity: ListTileControlAffinity.leading,
                secondary: IconButton(
                  icon: Icon(Icons.open_in_new),
                  onPressed: () async {
                    String url = 'https://grundid.de/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Can not launch $url';
                    }
                  },
                ),
              );
            },
            validator: (bool arg) {
              if (!_eula) {
                return 'Checkbox ausfüllen!';
              }
            },
          ),
          FormField(
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                title: Text('Datenschutzerklärung akzeptieren'),
                value: _privacy,
                onChanged: (value) {
                  setState(() {
                    _privacy = value;
                  });
                },
                activeColor: Colors.blue,
                controlAffinity: ListTileControlAffinity.leading,
                secondary: IconButton(
                  icon: Icon(Icons.open_in_new),
                  onPressed: () async {
                    String url = 'https://grundid.de/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Can not launch $url';
                    }
                  },
                ),
              );
            },
            validator: (bool arg) {
              if (!_privacy) {
                return 'Checkbox ausfüllen!';
              }
            },
          ),
        ],
      ),
    );
  }
}

class NameForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final OnChanged onChangedFirstName;
  final OnChanged onChangedLastName;
  final RegistrationModel registrationModel;
  NameForm({
    Key key,
    @required this.formKey,
    @required this.onChangedFirstName,
    @required this.onChangedLastName,
    this.registrationModel,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _NameFormState();
  }
}

class _NameFormState extends State<NameForm> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_firstNameListener);
    _lastNameController.addListener(_lastNameListener);
  }

  @override
  void dispose() {
    _firstNameController
      ..removeListener(_firstNameListener)
      ..dispose();
    _lastNameController
      ..removeListener(_lastNameListener)
      ..dispose();
    super.dispose();
  }

  void _firstNameListener() {
    widget.onChangedFirstName(_firstNameController.text);
  }

  void _lastNameListener() {
    widget.onChangedLastName(_lastNameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(helperText: "Vorname"),
            validator: (String value) {
              if (value.isEmpty) {
                return "Bitte Vorame eingeben";
              }
            },
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(helperText: "Nachname"),
            validator: (String value) {
              if (value.isEmpty) {
                return "Bitte Familienname eingeben";
              }
            },
          ),
        ],
      ),
    );
  }
}

class EmailRegistrationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final OnChanged onChangedEmail;
  final OnChanged onChangedPassword;

  const EmailRegistrationForm({
    Key key,
    @required this.formKey,
    @required this.onChangedEmail,
    @required this.onChangedPassword,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _EmailRegistrationFormState();
}

class _EmailRegistrationFormState extends State<EmailRegistrationForm> {
  String _password;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  _passwordListener() {
    setState(() {
      _password = _passwordController.text;
    });
    widget.onChangedPassword(_passwordController.text);
  }

  _emailListener() {
    widget.onChangedEmail(_emailController.text);
  }

  void initState() {
    super.initState();
    _passwordController.addListener(_passwordListener);
    _emailController.addListener(_emailListener);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController
      ..removeListener(_emailListener)
      ..dispose();
    _passwordController
      ..removeListener(_passwordListener)
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(helperText: 'E-Mail'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (String value) {
              if (value.isEmpty) {
                return 'Bitte E-Mail-Adresse eingeben!';
              }
            },
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(helperText: 'Passwort'),
            controller: _passwordController,
            validator: (String value) {
              if (value.isEmpty) {
                return 'Bitte Passwort eingeben!';
              }
            },
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(helperText: 'Passwort wiederholen'),
            validator: (String value) {
              if (_password != value) {
                return 'Passwort stimmt nicht überein!';
              }
            },
          ),
        ],
      ),
    );
  }
}
