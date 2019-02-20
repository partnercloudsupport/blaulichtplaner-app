import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

typedef void OnChanged(String value);

class TermsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final RegistrationModel registrationModel;

  const TermsForm(
      {Key key, @required this.formKey, @required this.registrationModel})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TermsFormState();
  }
}

class _TermsFormState extends State<TermsForm> {
  bool _eula = false;
  bool _privacy = false;

  @override
  void initState() {
    super.initState();
    _eula = widget.registrationModel.termsAccepted != null;
    _privacy = widget.registrationModel.privacyPolicyAccepted != null;
  }

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
    _firstNameController.text = widget.registrationModel.firstName;
    _firstNameController.addListener(_firstNameListener);
    _lastNameController.text = widget.registrationModel.lastName;
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
                return "Bitte Vornamen eingeben";
              }
            },
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(helperText: "Nachname"),
            validator: (String value) {
              if (value.isEmpty) {
                return "Bitte Familiennamen eingeben";
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
  final RegistrationModel registrationModel;
  final OnChanged onChangedEmail;
  final OnChanged onChangedPassword;

  const EmailRegistrationForm({
    Key key,
    @required this.formKey,
    @required this.onChangedEmail,
    @required this.onChangedPassword,
    @required this.registrationModel,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _EmailRegistrationFormState();
}

class _EmailRegistrationFormState extends State<EmailRegistrationForm> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  _passwordListener() {
    widget.onChangedPassword(_passwordController.text);
  }

  _emailListener() {
    widget.onChangedEmail(_emailController.text);
  }

  void initState() {
    super.initState();
    _emailController.text = widget.registrationModel.email;
    _passwordController.text = widget.registrationModel.password;
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
              if (_passwordController.text != value) {
                return 'Passwort stimmt nicht überein!';
              }
            },
          ),
        ],
      ),
    );
  }
}
