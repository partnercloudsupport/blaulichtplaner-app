import 'package:blaulichtplaner_app/api_service.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/login/registration_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../widgets/loader.dart';
import 'registration_form.dart';

class GoogleRegistrationScreen extends StatefulWidget {
  final FirebaseUser user;
  GoogleRegistrationScreen({Key key, @required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GoogleRegistrationScreenState();
}

class GoogleRegistrationScreenState extends State<GoogleRegistrationScreen> {
  bool _saving = false;
  bool _nameSaving = false;
  int _currentStep = 0;
  RegistrationModel _registrationModel;
  final _nameKey = GlobalKey<FormState>();
  final _termsKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    _registrationModel = RegistrationModel.fromUser(widget.user);
  }

  _updateProfileHandler() async {
    try {
      UserUpdateInfo info = UserUpdateInfo();
      info.displayName =
          '${_registrationModel.firstName} ${_registrationModel.lastName}';
      await widget.user.updateProfile(info);
      if (!widget.user.isEmailVerified) {
        await widget.user.sendEmailVerification();
      }
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
      _registrationModel.termsAccepted = DateTime.now();
      _registrationModel.privacyPolicyAccepted = DateTime.now();
      await FirestoreImpl.instance
          .collection('registrations')
          .document(widget.user.uid)
          .setData(_registrationModel.createData());
      RegistrationRequest request = RegistrationRequest(IOClient());
      await request.performPostRequest(
          widget.user.uid, "", "user", {"token": _registrationModel.token});
    } catch (e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler'),
        ),
      );
    }
  }

  _validate() {
    switch (_currentStep) {
      case 0:
        return _nameKey.currentState.validate();
        break;
      case 1:
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
            _nameSaving = true;
          });
          await _updateProfileHandler();
          setState(() {
            _nameSaving = false;
            _currentStep += 1;
          });
          break;
        case 1:
          setState(() {
            _saving = true;
          });
          await _saveDatabaseHandler();
          Navigator.pop(context, RegistrationResult(widget.user));
          break;
      }
    }
  }

  _onStepCancel() {}

  @override
  Widget build(BuildContext context) {
    List<Step> steps = <Step>[
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
        title: Text("Registrierung abschließen"),
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
