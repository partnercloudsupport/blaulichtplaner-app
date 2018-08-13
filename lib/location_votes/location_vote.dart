import 'package:cloud_firestore/cloud_firestore.dart';

class LocationVote{
  bool isAssigned = false;
  List<DocumentReference> employeeRefs;
  List<DocumentReference> locationRefs;
}