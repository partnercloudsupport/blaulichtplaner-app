import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Role {
  String type;
  String role;
  DocumentReference reference;
  String label;
  String locationLabel;
  DocumentReference locationRef;
  String companyLabel;
  DocumentReference companyRef;

  Role(this.type, this.role, this.reference, this.label, this.locationLabel,
      this.locationRef, this.companyLabel, this.companyRef);

  Role.fromSnapshot(Map<String, dynamic> data) {
    type = data["type"];
    role = data["role"];
    reference = data["reference"];
    label = data["label"] ??
        (data["locationName"] ??
            (data["employeeName"] ?? data["workAreaName"]));
    created = data["created"];
    locationLabel = data["locationLabel"];
    locationRef = data["locationRef"];
    companyLabel = data["companyLabel"];
    companyRef = data["companyRef"];
  }

  String companyId;
  String locationId;
  DateTime created;
}

class UserManager {
  static final UserManager _userManager = UserManager._();

  static UserManager get() {
    return _userManager;
  }

  final Map<String, List<Role>> _userRoles = {};
  final _companyLocationMatcher =
      RegExp(r"companies/(\d*\w*)/locations/(\d*\w*)/.*");
  FirebaseUser _user;
  get user => _user;

  UserManager._();

  Role _createRole(Map<String, dynamic> data) {
    Role role = Role.fromSnapshot(data);
    DocumentReference reference = data["reference"];
    String path = reference.path;
    final match = _companyLocationMatcher.firstMatch(path);

    if (match != null) {
      role.companyId = match.group(1);
      role.locationId = match.group(2);
    }

    return role;
  }

  void initWithDocuments(FirebaseUser user, List<DocumentSnapshot> docs) {
    _user = user;
    for (final doc in docs) {
      final type = doc.data["type"];
      List<Role> typeRoles = _userRoles[type];
      if (typeRoles == null) {
        typeRoles = [];
        _userRoles[type] = typeRoles;
      }
      typeRoles.add(_createRole(doc.data));
    }
  }

  List<Role> rolesForType(String type) {
    return _userRoles.containsKey(type) ? _userRoles[type] : [];
  }

  void clearRoles() {
    _userRoles.clear();
  }

  Role getRoleForTypeAndReference(String type, DocumentReference reference) {
    final match = _companyLocationMatcher.firstMatch(reference.path);

    if (match != null) {
      final companyId = match.group(1);
      final locationId = match.group(2);

      final roles = rolesForType(type);
      for (final role in roles) {
        if (role.companyId == companyId && role.locationId == locationId) {
          return role;
        }
      }
    }
    return null;
  }
}
