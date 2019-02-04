import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class UserManager {
  final Firestore _firestore = FirestoreImpl.instance;
  BlpUser _user;

  _decideValue(String value, String fallback) {
    if (value != null && value.isNotEmpty) {
      return value;
    } else {
      return fallback;
    }
  }

  _createDisplayName(String firstName, String lastName) {
    if (firstName != null && lastName != null) {
      return (firstName + " " + lastName).trim();
    } else {
      return null;
    }
  }

  ///  returns true if the user is registered
  Future<BlpUser> initUser(FirebaseUser user) async {
    if (user != null) {
      DocumentReference userRef = _firestore.document("users/${user.uid}");
      DocumentSnapshot userSnapshot = await userRef.document;
      if (userSnapshot.exists) {
        final data = userSnapshot.data;
        String firstName = data["firstName"];
        String lastName = data["lastName"];
        String photoURL = data["photoURL"];
        DateTime privacyPolicyAccepted = data["privacyPolicyAccepted"];
        DateTime termsAccepted = data["termsAccepted"];

        _user = BlpUser(
            user.uid,
            userSnapshot.reference,
            _decideValue(
                _createDisplayName(firstName, lastName), user.displayName),
            _decideValue(photoURL, user.photoUrl),
            user.email,
            user.isEmailVerified,
            true,
            privacyPolicyAccepted,
            termsAccepted);

        await _initRoles(userSnapshot.reference);
        print("User init done");
      } else {
        _user = BlpUser.registrationIncomplete(user.uid, user.displayName,
            user.photoUrl, user.email, user.isEmailVerified);
      }
      return _user;
    } else {
      return null;
    }
  }

  Future<void> _initRoles(DocumentReference userRef) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("roles")
        .where("userRef", isEqualTo: userRef)
        .getDocuments();

    for (DocumentSnapshot snapshot in querySnapshot.documents) {
      String type = snapshot.get("type");
      String role = snapshot.get("role");
      RoleType key = RoleType(role, type);
      _user.addRole(key, UserRole.fromSnapshot(snapshot));
    }
  }

  void logout() {
    _user = null;
  }
}

class UserWidget extends InheritedWidget {
  final BlpUser user;

  UserWidget({Key key, @required Widget child, @required this.user})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    print("updateShouldNotify!!");
    return true;
  }

  static UserWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(UserWidget);
  }
}
