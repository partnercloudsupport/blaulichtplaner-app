import 'package:cloud_firestore/cloud_firestore.dart';

class InvitationModel {
  DocumentReference selfRef;
  String companyLabel;
  DocumentReference companyRef;
  DateTime created;
  DateTime updated;
  String email;
  DocumentReference employeeRef;
  String invitationText;
  String invitedBy;
  String invitedById;
  InvitationModel.fromSnapshot(DocumentSnapshot snapshot) {
    selfRef = snapshot.reference;
    companyLabel = snapshot.data['companyLabel'];
    companyRef = snapshot.data['companyRef'];
    created = snapshot.data['created'];
    updated = snapshot.data['updated'];
    email = snapshot.data['email'];
    employeeRef = snapshot.data['employeeRef'];
    invitationText = snapshot.data['invitationText'];
    invitedBy = snapshot.data['invitedBy'];
    invitedById = snapshot.data['invitedById'];
  }
}
