import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/login/registration_service.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/loader.dart';
import 'registration_form.dart';

class RegistrationScreen extends StatefulWidget {
  final FirebaseUser user;
  final String photoUrl;

  const RegistrationScreen({Key key, this.user, this.photoUrl})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RegistrationScreenState();
  }
}

class RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 0;
  int _startStep = 0;
  bool _saving = false;
  RegistrationModel _registrationModel = RegistrationModel();

  final _emailKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  final _termsKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _currentStep = 1;
      _startStep = 1;
      _registrationModel = RegistrationModel.fromUser(
          widget.user.displayName, widget.user.email, widget.photoUrl);
    }
  }

  Widget _buildDialog(BuildContext context, String errorMessage) {
    return AlertDialog(
      title: Text("Fehler bei der Registrierung"),
      content: Text(errorMessage),
      actions: <Widget>[
        FlatButton(
          child: Text("Daten korrigieren"),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        FlatButton(
          child: Text("Abbrechen"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        )
      ],
    );
  }

  Widget _buildInfoDialog(BuildContext context, String message) {
    return AlertDialog(
      title: Text("Registrierung erfolgreich"),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  Future _saveUser() async {
    if (widget.user != null) {
      return _saveUserWithAccount();
    } else {
      return _saveUserWithEmailAndPassword();
    }
  }

  Future _saveUserWithAccount() async {
    setState(() {
      _saving = true;
    });
    await UserRegistration(
            FirestoreImpl.instance, ActionContext(null, null, null))
        .performAction(RegistrationAction(widget.user.uid, _registrationModel));

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _buildInfoDialog(
              context, "Sie werden jetzt in der App angemeldet.");
        });
    Navigator.pop(context, RegistrationResult(widget.user));
  }

  Future _saveUserWithEmailAndPassword() async {
    setState(() {
      _saving = true;
    });
    try {
      await RegistrationService()
          .registerWithEmailAndPassword(_registrationModel);
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return _buildInfoDialog(context,
                "Wir haben Ihnen eine E-Mail mit einem Bestätigungslink geschickt. Bitte prüfen Sie ihr Postfach und bestätigen Sie Ihre E-Mail Adresse.");
          });
      Navigator.pop(context);
    } on PlatformException catch (e) {
      bool repeat = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            print(e);
            String errorMessage = e.message;
            switch (e.code) {
              case "ERROR_EMAIL_ALREADY_IN_USE":
                errorMessage =
                    "Der Benutzter existiert bereits. Bitte loggen Sich sich damit ein oder erstellen Sie einen anderen Benutzer.";
                break;
              case "ERROR_WEAK_PASSWORD":
                errorMessage =
                    "Das Passwort ist zu einfach. Bitte geben Sie in anderes Passwort ein.";
                break;
              case "ERROR_INVALID_EMAIL":
                errorMessage =
                    "Die E-Mail Adresse ist ungültig. Bitte korrigieren Sie die E-Mail Adresse";
                break;
              default:
            }
            return _buildDialog(context, errorMessage);
          });
      if (repeat) {
        setState(() {
          _currentStep = 0;
          _saving = false;
        });
      } else {
        Navigator.pop(context);
      }
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
    if (step < _currentStep) {
      setState(() {
        _currentStep = step;
      });
    } else {
      if (_validate()) {
        setState(() {
          _currentStep = step;
        });
      }
    }
  }

  _onStepContinue() async {
    if (_validate()) {
      switch (_currentStep) {
        case 0:
          setState(() {
            _currentStep += 1;
          });
          break;
        case 1:
          setState(() {
            _currentStep += 1;
          });
          break;
        case 2:
          _saveUser();
          break;
      }
    }
  }

  _onStepCancel() {
    if (_currentStep == _startStep) {
      Navigator.maybePop(context);
    } else {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = <Step>[
      Step(
        state: widget.user != null ? StepState.disabled : StepState.indexed,
        title: Text('E-Mail und Passwort'),
        subtitle: Text('Legen Sie Ihre Login-Daten fest.'),
        content: EmailRegistrationForm(
          formKey: _emailKey,
          registrationModel: _registrationModel,
          onChangedEmail: (String val) {
            _registrationModel.email = val;
          },
          onChangedPassword: (String val) {
            _registrationModel.password = val;
          },
        ),
      ),
      Step(
        title: Text('Persönliche Daten'),
        subtitle: Text('Passen Sie Ihre Daten an!'),
        content: NameForm(
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
      Step(
        title: Text('AGBs akzeptieren'),
        subtitle: Text('Rechtliches'),
        content: TermsForm(
          registrationModel: _registrationModel,
          formKey: _termsKey,
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrieren"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_currentStep == _startStep) {
            return true;
          } else {
            _onStepCancel();
            return false;
          }
        },
        child: LoaderBodyWidget(
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
      ),
    );
  }
}
