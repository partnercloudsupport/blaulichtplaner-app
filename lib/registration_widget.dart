import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:secure_string/secure_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_app/api_service.dart';

class RegistrationModel {
  String firstName;
  String lastName;
  String email;
  DateTime privacyPolicyAccepted;
  DateTime termsAccepted;
  String token;

  RegistrationModel.fromUser(FirebaseUser user) {
    firstName = user.displayName.split(" ")[0];
    lastName = user.displayName.split(" ")[1];
    email = user.email;
    token = SecureString().generate(length: 64);
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

class RegistrationScreen extends StatelessWidget {
  final FirebaseUser user;
  final Function successCallback;
  RegistrationScreen({Key key, @required this.user, @required this.successCallback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrieren")),
      body: RegistrationForm(
        user: user,
        successCallback: successCallback,
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  final FirebaseUser user;
  final Function successCallback;
  RegistrationForm({Key key, @required this.user, @required this.successCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RegistrationFormState();
  }
}

class RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  RegistrationModel _registrationModel;
  TextEditingController firstNameController;
  TextEditingController lastNameController;
  TextEditingController emailController;
  bool _validated = false;

  @override
  void initState() {
    super.initState();
    _registrationModel = RegistrationModel.fromUser(widget.user);
    firstNameController =
        TextEditingController(text: _registrationModel.firstName)
          ..addListener(_firstNameListener);
    lastNameController =
        TextEditingController(text: _registrationModel.lastName)
          ..addListener(_lastNameListener);
    emailController = TextEditingController(text: _registrationModel.email)
      ..addListener(_emailListener);
  }

  @override
  void dispose() {
    firstNameController
      ..removeListener(_firstNameListener)
      ..dispose();
    lastNameController
      ..removeListener(_lastNameListener)
      ..dispose();
    emailController
      ..removeListener(_emailListener)
      ..dispose();
    super.dispose();
  }

  void _firstNameListener() {
    _registrationModel.firstName = firstNameController.text;
  }

  void _lastNameListener() {
    _registrationModel.lastName = lastNameController.text;
  }

  void _emailListener() {
    _registrationModel.email = emailController.text;
  }

  _saveRegistration() async {
    try {
      await Firestore.instance
          .collection('registrations')
          .document(widget.user.uid)
          .setData(_registrationModel.createData());
      RegistrationRequest request = RegistrationRequest(IOClient());
      await request.performPostRequest(widget.user.uid, "", "user", {"token": _registrationModel.token});
      widget.successCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller:
                    TextEditingController(text: _registrationModel.firstName),
                decoration: InputDecoration(helperText: "Vorname"),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Bitte Vorame eingeben";
                  }
                },
              ),
              TextFormField(
                controller:
                    TextEditingController(text: _registrationModel.lastName),
                decoration: InputDecoration(helperText: "Nachname"),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Bitte Familienname eingeben";
                  }
                },
              ),
              TextFormField(
                controller:
                    TextEditingController(text: _registrationModel.email),
                decoration: InputDecoration(helperText: "EMail"),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Bitte EMail eingeben";
                  }
                },
              ),
              FormField(
                builder: (FormFieldState<String> arg) {
                  return CheckboxListTile(
                    title: Text('AGBs akzeptieren'),
                    value: _registrationModel.termsAccepted != null,
                    onChanged: (value) {
                      setState(() {
                        _registrationModel.termsAccepted =
                            value ? DateTime.now() : null;
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
                validator: (String arg) {
                  if (_registrationModel.termsAccepted == null) {
                    return 'Checkbox ausfüllen!';
                  }
                },
              ),
              FormField(
                initialValue: _registrationModel.email,
                builder: (FormFieldState<String> arg) {
                  return CheckboxListTile(
                    title: Text('Datenschutzerklärung akzeptieren'),
                    value: _registrationModel.privacyPolicyAccepted != null,
                    onChanged: (value) {
                      setState(() {
                        _registrationModel.privacyPolicyAccepted =
                            value ? DateTime.now() : null;
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
                validator: (String arg) {
                  if (_registrationModel.privacyPolicyAccepted == null) {
                    return 'Checkbox ausfüllen!';
                  }
                },
              ),
              LoaderWidget(
                loading: _validated,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        _validated = true;
                      });
                      _saveRegistration();
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Bitte alle Felder ausfüllen'),
                          ));
                    }
                  },
                  child: Text('Bestätigen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
