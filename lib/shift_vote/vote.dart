import 'dart:async';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

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
      final collection = FirestoreImpl.instance.collection("shiftVotes");
      final ref = await collection.add(data);
      return ref;
    }
  }

  Future<void> delete(Vote vote) {
    return vote.selfRef.delete();
  }
}

