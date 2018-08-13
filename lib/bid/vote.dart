import 'dart:async';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blaulichtplaner_app/bid/shift_vote.dart';

abstract class Vote {
  bool isBid;
  DateTime from;
  DateTime to;
  DateTime created;
  DocumentReference shiftplanRef;
  DocumentReference shiftRef;
  DocumentReference employeeRef;
  String employeeLabel;
  DocumentReference selfRef;
}

class VoteService {
  Future<DocumentReference> save(Vote vote) async {
    final data = <String, dynamic>{};
    data["isBid"] = vote.isBid;
    data["from"] = vote.from;
    data["to"] = vote.to;
    data["shiftplanRef"] = vote.shiftplanRef;
    data["shiftRef"] = vote.shiftRef;
    data["employeeRef"] = vote.employeeRef;
    data["employeeLabel"] = vote.employeeLabel;
    if (vote.selfRef != null) {
      await vote.selfRef.setData(data);
      return vote.selfRef;
    } else {
      final collection = Firestore.instance.collection("shiftVotes");
      final ref = await collection.add(data);
      return ref;
    }
  }

  Future<void> delete(Vote vote) {
    return vote.selfRef.delete();
  }
}

class Bid extends Vote {
  bool isBid = true;
  Bid();

  Bid.fromShift(Shift shift, Role role) {
    created = DateTime.now();
    shiftplanRef = shift.shiftplanRef;
    shiftRef = shift.shiftRef;
    employeeRef = role.reference;
    employeeLabel = role.label;
    from = shift.from;
    to = shift.to;
  }

  Bid.fromSnapshot(DocumentSnapshot document) {
    shiftRef = document.data["shiftRef"];
    shiftplanRef = document.data["shiftplanRef"];
    employeeRef = document.data["employeeRef"];
    selfRef = document.reference;
    from = document.data["from"];
    to = document.data["to"];
    created = document.data["created"];
    employeeLabel = document.data["employeeLabel"];
  }
}

class Rejection extends Vote {
  bool isBid = false;
  Rejection();

  Rejection.fromShift(Shift shift, Role role) {
    created = DateTime.now();
    shiftplanRef = shift.shiftplanRef;
    shiftRef = shift.shiftRef;
    employeeRef = role.reference;
    employeeLabel = role.label;
    from = shift.from;
    to = shift.to;
  }

  Rejection.fromSnapshot(DocumentSnapshot document) {
    shiftRef = document.data["shiftRef"];
    shiftplanRef = document.data["shiftplanRef"];
    employeeRef = document.data["employeeRef"];
    selfRef = document.reference;
    from = document.data["from"];
    to = document.data["to"];
    created = document.data["created"];
    employeeLabel = document.data["employeeLabel"];
  }
}
