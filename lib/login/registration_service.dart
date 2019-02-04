import 'package:blaulichtplaner_app/api_service.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/login/registration_form.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

class RegistrationResult {
  final FirebaseUser user;
  RegistrationResult(this.user);
}

Future<FirebaseUser> registerWithEmailAndPassword(
    RegistrationModel _registrationModel,
    String _email,
    String _password) async {
  FirebaseUser _user =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _email,
    password: _password,
  );
  _registrationModel = RegistrationModel.fromUser(_user);
  UserUpdateInfo info = UserUpdateInfo();
  info.displayName =
      '${_registrationModel.firstName} ${_registrationModel.lastName}';
  await _user.updateProfile(info);
  if (!_user.isEmailVerified) {
    await _user.sendEmailVerification();
  }
  _registrationModel.termsAccepted = DateTime.now();
  _registrationModel.privacyPolicyAccepted = DateTime.now();
  await FirestoreImpl.instance
      .collection('registrations')
      .document(_user.uid)
      .setData(_registrationModel.createData());
  RegistrationRequest request = RegistrationRequest(IOClient());
  await request.performPostRequest(
    _user.uid,
    "",
    "user",
    {"token": _registrationModel.token},
  );
  return _user;
}
