import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationResult {
  final FirebaseUser user;
  RegistrationResult(this.user);
}

class RegistrationService {
  Future<void> registerWithEmailAndPassword(
      RegistrationModel registrationModel) async {
    FirebaseUser _user =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: registrationModel.email,
      password: registrationModel.password,
    );
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName =
        '${registrationModel.firstName} ${registrationModel.lastName}';
    await _user.updateProfile(info);
    if (!_user.isEmailVerified) {
      await _user.sendEmailVerification();
    }

    await UserRegistration(
            FirestoreImpl.instance, ActionContext(null, null, null))
        .performAction(RegistrationAction(_user.uid, registrationModel));
    FirebaseAuth.instance.signOut();
  }
}
