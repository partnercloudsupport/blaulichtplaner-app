import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class Bid {
  DocumentReference selfRef;
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();
  int minHours = 0;
  int maxHours = 0;
  String remarks;
  DocumentReference shiftplanRef;
  DocumentReference shiftRef;
  DocumentReference employeeRef;
  String employeeLabel;

  Bid();

  Bid.fromSnapshot(DocumentSnapshot document) {
    selfRef = document.reference;
    from = document.data["from"];
    to = document.data["to"];
    minHours = document.data["minHours"];
    maxHours = document.data["maxHours"];
    remarks = document.data["remarks"];
    shiftRef = document.data["shiftRef"];
    shiftplanRef = document.data["shiftplanRef"];
    employeeRef = document.data["employeeRef"];
  }
}

class BidService {
  Future<DocumentReference> saveBid(Bid bid) async {
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

  Future<void> deleteBid(Bid bid) {
    return bid.selfRef.delete();
  }
}
