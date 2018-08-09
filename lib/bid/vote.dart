import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blaulichtplaner_app/bid/shift_vote.dart';

abstract class Vote {
  DateTime from;
  DateTime to;
  DateTime created;
  DocumentReference shiftplanRef;
  DocumentReference shiftRef;
  DocumentReference employeeRef;
  DocumentReference selfRef;
}

abstract class VoteService {
  Future<DocumentReference> save(Vote vote);
  Future<void> delete(Vote vote);
}

class Bid extends Vote {
  int minHours = 0;
  int maxHours = 0;
  String remarks;
  String employeeLabel;

  Bid();

  Bid.fromShift(Shift shift, DocumentReference employeeRef) {
    created = DateTime.now();
    shiftplanRef = shift.shiftplanRef;
    shiftplanRef = shift.shiftRef;
    this.employeeRef = employeeRef;
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
    minHours = document.data["minHours"];
    maxHours = document.data["maxHours"];
    remarks = document.data["remarks"];
    employeeLabel = document.data["employeeLabel"];
  }
}

class Rejection extends Vote {
  Rejection();

  Rejection.fromShift(Shift shift, DocumentReference employeeRef) {
    created = DateTime.now();
    shiftplanRef = shift.shiftplanRef;
    shiftRef = shift.shiftRef;
    this.employeeRef = employeeRef;
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
  }
}

class BidService extends VoteService {
  Future<DocumentReference> save(Vote vote) async {
    Bid bid = vote as Bid;
    final data = <String, dynamic>{};
    data["from"] = bid.from;
    data["to"] = bid.to;
    data["minHours"] = bid.minHours;
    data["maxHours"] = bid.maxHours;
    data["remarks"] = bid.remarks;
    data["shiftplanRef"] = bid.shiftplanRef;
    data["shiftRef"] = bid.shiftRef;
    data["employeeRef"] = bid.employeeRef;
    data["employeeLabel"] = bid.employeeLabel;
    if (bid.selfRef != null) {
      await bid.selfRef.setData(data);
      return bid.selfRef;
    } else {
      final collection = Firestore.instance.collection("bids");
      final ref = await collection.add(data);
      return ref;
    }
  }

  Future<void> delete(Vote vote) {
    return vote.selfRef.delete();
  }
}

class RejectionService extends VoteService {
  Future<DocumentReference> save(Vote vote) {
    Rejection rejection = vote as Rejection;
    Map<String, dynamic> data = {};
    data["created"] = rejection.created;
    data["shiftplanRef"] = rejection.shiftplanRef;
    data["shiftRef"] = rejection.shiftRef;
    data["from"] = rejection.from;
    data["to"] = rejection.to;
    data["employeeRef"] = rejection.employeeRef;

    return Firestore.instance.collection("rejections").add(data);
  }

  Future<void> delete(Vote vote) {
    return vote.selfRef.delete();
  }
}