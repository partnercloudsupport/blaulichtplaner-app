import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Role {
  String label;
  DocumentReference reference;
  String role;
  String type;
  DocumentReference employeeRef;
  Timestamp created;

  Role.fromSnapshot(Map<String, dynamic> data) {
    label = data["label"];
    reference = data["reference"];
    role = data["role"];
    type = data["type"];
    employeeRef = data["employeeRef"];
    created = data["created"];
  }
}

class UserManager {
  static final UserManager _userManager = UserManager._();

  static UserManager get() {
    return _userManager;
  }

  final Map<String, List<Role>> _userRoles = {};
  FirebaseUser _user;
  get user => _user;

  UserManager._();

  void initWithDocuments(FirebaseUser user, List<DocumentSnapshot> docs) {
    _user = user;
    for (final doc in docs) {
      final role = doc.data["role"];
      List<Role> typeRoles = _userRoles.putIfAbsent(role, () => []);
      Role userRole = Role.fromSnapshot(doc.data);
      print("Adding role: ${userRole.type}, employeeRef: ${userRole.employeeRef}");
      typeRoles.add(userRole);
    }
  }

  List<Role> employeeRoles() {
    return _userRoles.containsKey("employee") ? _userRoles["employee"] : [];
  }

  bool hasEmployeeRoles() {
    List<Role> roles = employeeRoles();
    return roles.isNotEmpty;
  }

  void clearRoles() {
    _userRoles.clear();
  }

  @deprecated
  Role getRoleForTypeAndReference(String type, DocumentReference reference) {
    final roles = employeeRoles();
    return roles.firstWhere((role) => role.reference == reference);
  }
}
