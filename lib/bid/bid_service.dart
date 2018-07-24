import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class Bid {
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();
  int minHours = 0;
  int maxHours = 0;
  String remarks;
  DocumentReference workAreaRef;
  DocumentReference shiftplanRef;
  DocumentReference shiftRef;
  DocumentReference employeeRef;
  String employeeLabel;
  String workAreaLabel;
}

class BisService {
  Future<DocumentReference> saveBid(DocumentReference bidRef, Bid bid) async {
    final data = {};
    data["from"] = bid.from;
    data["to"] = bid.to;
    data["minHours"] = bid.minHours;
    data["maxHours"] = bid.maxHours;
    data["remarks"] = bid.remarks;
    data["workAreaRef"] = bid.workAreaRef;
    data["shiftplanRef"] = bid.shiftplanRef;
    data["shiftRef"] = bid.shiftRef;
    data["employeeRef"] = bid.employeeRef;
    data["employeeLabel"] = bid.employeeLabel;
    data["workAreaLabel"] = bid.workAreaLabel;
    if (bidRef != null) {
      await bidRef.setData(data);
      return bidRef;
    } else {
      return Firestore.instance.collection("bids").add(data);
    }
  }
}
