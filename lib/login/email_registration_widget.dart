import 'package:blaulichtplaner_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'registration_form.dart';
import '../widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailRegistrationScreen extends StatefulWidget {
  final Function successCallback;

  const EmailRegistrationScreen({Key key, @required this.successCallback})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EmailRegistrationScreenState();
  }
}

class EmailRegistrationScreenState extends State<EmailRegistrationScreen> {
  FirebaseUser _user;
  int _currentStep = 0;
  bool _emailSaving = false;
  bool _nameSaving = false;
  bool _saving = false;
  RegistrationModel _registrationModel;

  final _emailKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  final _termsKey = GlobalKey<FormState>();

  String _password;
  String _email;

  _emailRegistrationHandler() async {
    try {
      _user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      _registrationModel = RegistrationModel.fromUser(_user);
    } catch (e) {
      print(e.toString());
    }
  }

  _updateProfileHandler() async {
    try {
      UserUpdateInfo info = UserUpdateInfo();
      info.displayName =
          '${_registrationModel.firstName} ${_registrationModel.lastName}';
      await FirebaseAuth.instance.updateProfile(info);
      if (!_user.isEmailVerified) {
        await _user.sendEmailVerification();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _saveDatabaseHandler() async {
    try {
      _registrationModel.termsAccepted = DateTime.now();
      _registrationModel.privacyPolicyAccepted = DateTime.now();
      await Firestore.instance
          .collection('registrations')
          .document(_user.uid)
          .setData(_registrationModel.createData());
      RegistrationRequest request = RegistrationRequest(IOClient());
      await request.performPostRequest(
          _user.uid, "", "user", {"token": _registrationModel.token});
    } catch (e) {
      print(e.toString());
    }
  }

  _validate() {
    switch (_currentStep) {
      case 0:
        return _emailKey.currentState.validate();
        break;
      case 1:
        return _nameKey.currentState.validate();
        break;
      case 2:
        return _termsKey.currentState.validate();
        break;
      default:
        return false;
    }
  }

  _onStepTapped(int step) {
    if (_validate()) {
      setState(() {
        _currentStep = _currentStep;
      });
    }
  }

  _onStepContinue() async {
    if (_validate()) {
      switch (_currentStep) {
        case 0:
          setState(() {
            _emailSaving = true;
          });
          await _emailRegistrationHandler();
          setState(() {
            _emailSaving = false;
            _currentStep += 1;
          });
          break;
        case 1:
          setState(() {
            _nameSaving = true;
          });
          await _updateProfileHandler();
          setState(() {
            _nameSaving = false;
            _currentStep += 1;
          });
          break;
        case 2:
          setState(() {
            _saving = true;
          });
          await _saveDatabaseHandler();
          widget.successCallback();
          Navigator.pop(context);
          break;
      }
    }
  }

  _onStepCancel() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = <Step>[
      Step(
        title: Text('E-Mail und Passwort'),
        subtitle: Text('Legen Sie Ihre Login-Daten fest.'),
        content: LoaderWidget(
          loading: _emailSaving,
          child: EmailRegistrationForm(
            formKey: _emailKey,
            onChangedEmail: (String val) {
              _email = val;
            },
            onChangedPassword: (String val) {
              _password = val;
            },
          ),
        ),
      ),
      Step(
        title: Text('Persönliche Daten'),
        subtitle: Text('Passen Sie Ihre Daten an!'),
        content: LoaderWidget(
          loading: _nameSaving,
          child: NameForm(
            formKey: _nameKey,
            registrationModel: _registrationModel,
            onChangedFirstName: (String val) {
              _registrationModel.firstName = val;
            },
            onChangedLastName: (String val) {
              _registrationModel.lastName = val;
            },
          ),
        ),
      ),
      Step(
        title: Text('AGBs akzeptieren'),
        subtitle: Text('Blabla'),
        content: TermsForm(
          formKey: _termsKey,
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrieren"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_currentStep == 0) {
              Navigator.maybePop(context);
            } else {
              _onStepCancel();
            }
          },
        ),
      ),
      body: LoaderBodyWidget(
        empty: false,
        loading: _saving,
        child: Stepper(
          currentStep: _currentStep,
          onStepCancel: _onStepCancel,
          onStepTapped: _onStepTapped,
          onStepContinue: _onStepContinue,
          steps: steps,
        ),
      ),
    );
  }
}
