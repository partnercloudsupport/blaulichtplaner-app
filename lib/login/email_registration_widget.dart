import 'package:blaulichtplaner_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'registration_form.dart';
import '../widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailRegistrationScreen extends StatefulWidget {
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

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  _emailRegistrationHandler() async {
    try {
      _user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _registrationModel = RegistrationModel.fromUser(_user);
    } catch (e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Versuchen Sie es noch einmal!'),
        ),
      );
    }
  }

  _updateProfileHandler() async {
    try {
      UserUpdateInfo info = UserUpdateInfo();
      info.displayName =
          '${_registrationModel.firstName} ${_registrationModel.lastName}';
      await FirebaseAuth.instance.updateProfile(info);
      await _user.sendEmailVerification();
    } catch (e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler'),
        ),
      );
    }
  }

  _saveDatabaseHandler() async {
    try {
      await Firestore.instance
          .collection('registrations')
          .document(_user.uid)
          .setData(_registrationModel.createData());
      RegistrationRequest request = RegistrationRequest(IOClient());
      await request.performPostRequest(
          _user.uid, "", "user", {"token": _registrationModel.token});
      UserUpdateInfo info = UserUpdateInfo();
      info.displayName =
          '${_registrationModel.firstName} ${_registrationModel.lastName}';
      await FirebaseAuth.instance.updateProfile(info);
    } catch (e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler'),
        ),
      );
    }
  }

  final _emailKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  final _termsKey = GlobalKey<FormState>();

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
            emailController: _emailController,
            passwordController: _passwordController,
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
              onChange: (RegistrationModel r) {
                _registrationModel = r;
              }),
        ),
      ),
      Step(
        title: Text('AGBs akzeptieren'),
        subtitle: Text('Blabla'),
        content: TermsForm(
          formKey: _termsKey,
          registrationModel: _registrationModel,
          onChange: (RegistrationModel r) {
            _registrationModel = r;
          },
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrieren"),
        leading: _currentStep == 0 ? BackButton() : null,
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
