import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nanoid/nanoid.dart';
import 'package:url_launcher/url_launcher.dart';

typedef void OnChange(RegistrationModel r);

class RegistrationModel {
  String firstName = '';
  String lastName = '';
  String email;
  DateTime privacyPolicyAccepted;
  DateTime termsAccepted;
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
  final RegistrationModel registrationModel;
  final GlobalKey<FormState> formKey;
  final OnChange onChange;
  const TermsForm(
      {Key key, @required this.registrationModel, this.formKey, this.onChange})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TermsFormState();
  }
}

class _TermsFormState extends State<TermsForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          FormField(
            builder: (FormFieldState<String> arg) {
              return CheckboxListTile(
                title: Text('AGBs akzeptieren'),
                value: widget.registrationModel.termsAccepted != null,
                onChanged: (value) {
                  setState(() {
                    widget.registrationModel.termsAccepted =
                        value ? DateTime.now() : null;
                  });
                  widget.onChange(widget.registrationModel);
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
            validator: (String arg) {
              if (widget.registrationModel.termsAccepted == null) {
                return 'Checkbox ausfüllen!';
              }
            },
          ),
          FormField(
            builder: (FormFieldState<String> arg) {
              return CheckboxListTile(
                title: Text('Datenschutzerklärung akzeptieren'),
                value: widget.registrationModel.privacyPolicyAccepted != null,
                onChanged: (value) {
                  setState(() {
                    widget.registrationModel.privacyPolicyAccepted =
                        value ? DateTime.now() : null;
                  });
                  widget.onChange(widget.registrationModel);
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
            validator: (String arg) {
              if (widget.registrationModel.privacyPolicyAccepted == null) {
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
  final RegistrationModel registrationModel;
  final Function successCallback;
  final GlobalKey<FormState> formKey;
  final OnChange onChange;
  NameForm(
      {Key key,
      @required this.registrationModel,
      this.successCallback,
      this.formKey, this.onChange})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _NameFormState();
  }
}

class _NameFormState extends State<NameForm> {
  TextEditingController firstNameController;
  TextEditingController lastNameController;
  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: widget.registrationModel.firstName)
          ..addListener(_firstNameListener);
    lastNameController =
        TextEditingController(text: widget.registrationModel.lastName)
          ..addListener(_lastNameListener);
  }

  @override
  void dispose() {
    firstNameController
      ..removeListener(_firstNameListener)
      ..dispose();
    lastNameController
      ..removeListener(_lastNameListener)
      ..dispose();
    super.dispose();
  }

  void _firstNameListener() {
    widget.registrationModel.firstName = firstNameController.text;
    widget.onChange(widget.registrationModel);
  }

  void _lastNameListener() {
    widget.registrationModel.lastName = lastNameController.text;
    widget.onChange(widget.registrationModel);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller:
                TextEditingController(text: widget.registrationModel.firstName),
            decoration: InputDecoration(helperText: "Vorname"),
            validator: (String value) {
              if (value.isEmpty) {
                return "Bitte Vorame eingeben";
              }
            },
          ),
          TextFormField(
            controller:
                TextEditingController(text: widget.registrationModel.lastName),
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
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const EmailRegistrationForm({
    Key key,
    @required this.formKey,
    @required this.emailController,
    @required this.passwordController,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _EmailRegistrationFormState();
}

class _EmailRegistrationFormState extends State<EmailRegistrationForm> {
  String _password;
  String _email;

  _passwordListener() {
    setState(() {
      _password = widget.passwordController.text;
    });
  }

  _emailListener() {
    setState(() {
      _email = widget.emailController.text;
    });
  }

  void initState() {
    super.initState();
    widget.passwordController.addListener(_passwordListener);
    widget.emailController.addListener(_emailListener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.emailController
      ..removeListener(_emailListener)
      ..dispose();
    widget.passwordController
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
            controller: widget.emailController,
            validator: (String value) {
              if (value.isEmpty) {
                return 'Bitte E-Mail-Adresse eingeben!';
              }
            },
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(helperText: 'Passwort'),
            controller: widget.passwordController,
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
