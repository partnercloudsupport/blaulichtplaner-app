import 'dart:async';

import 'package:blaulichtplaner_app/bid/shift_bids.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rejection {
  DocumentReference shiftplanRef;
  DocumentReference shiftRef;
  DateTime from;
  DateTime to;
  DateTime created;
  DocumentReference employeeRef;

  Rejection.fromShift(Shift shift, DocumentReference employeeRef) {
    created = DateTime.now();
    shiftplanRef = shift.shiftplanRef;
    shiftRef = shift.shiftRef;
    from = shift.from;
    to = shift.to;
    this.employeeRef = employeeRef;
  }

  Rejection.fromSnapshot(DocumentSnapshot document) {
    shiftRef = document.data["shiftRef"];
  }
}

Future<DocumentReference> rejectShift(Rejection rejection) {
  Map<String, dynamic> data = {};
  data["created"] = rejection.created;
  data["shiftplanRef"] = rejection.shiftplanRef;
  data["shiftRef"] = rejection.shiftRef;
  data["from"] = rejection.from;
  data["to"] = rejection.to;
  data["employeeRef"] = rejection.employeeRef;

  return Firestore.instance.collection("rejections").add(data);
}
