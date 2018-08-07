import 'package:blaulichtplaner_app/bid/bid_service.dart';
import 'package:blaulichtplaner_app/bid/rejection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Shift {
  String id;
  DocumentReference shiftRef;
  DateTime from;
  DateTime to;
  String workAreaLabel;
  String locationLabel;
  DocumentReference shiftplanRef;
  DocumentReference workAreaRef;
  String publicNote;

  Shift.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    shiftRef = snapshot.reference;
    from = snapshot.data["from"];
    to = snapshot.data["to"];
    workAreaLabel = snapshot.data["workAreaLabel"];
    locationLabel = snapshot.data["locationLabel"];
    shiftplanRef = snapshot.data["shiftplanRef"];
    workAreaRef = snapshot.data["workAreaRef"];
    publicNote = snapshot.data["publicNote"];
  }
}

class ShiftBid {
  Shift shift;
  Bid bid;

  ShiftBid({this.shift, this.bid});

  DateTime get from {
    if (shift != null) {
      return shift.from;
    } else {
      return bid.from;
    }
  }

  DateTime get to {
    if (shift != null) {
      return shift.to;
    } else {
      return bid.to;
    }
  }

  String get workAreaLabel {
    if (shift != null) {
      return shift.workAreaLabel;
    } else {
      return "Eigene Bewerbung";
    }
  }
  String get locationLabel {
    if (shift != null) {
      return shift.locationLabel;
    } else {
      return "Unbekannter Ort";
    }
  }

  DocumentReference get shiftplanRef {
    if (shift != null) {
      return shift.shiftplanRef;
    } else {
      return bid.shiftplanRef;
    }
  }

  DocumentReference get shiftRef {
    if (shift != null) {
      return shift.shiftRef;
    } else {
      return bid.shiftRef;
    }
  }

  bool hasShift() {
    return shift != null;
  }

  bool hasBid() {
    return bid != null;
  }
}

class ShiftBidHolder {
  final List<ShiftBid> _shiftBids = [];
  final Set<DocumentReference> rejectedShifts = Set();

  int get length => _shiftBids.length;

  bool get isEmpty => _shiftBids.isEmpty;

  void clear() {
    _shiftBids.clear();
  }

  ShiftBid operator [](int index) {
    return _shiftBids[index];
  }

  void addBid(Bid bid) {
    if (bid.shiftRef != null) {
      final shiftBid = _findByShiftRef(bid.shiftRef);
      if (shiftBid == null) {
        _shiftBids.add(ShiftBid(bid: bid));
      } else {
        shiftBid.bid = bid;
      }
    } else {
      _shiftBids.add(ShiftBid(bid: bid));
    }
  }

  void addShift(Shift shift) {
    if (!rejectedShifts.contains(shift.shiftRef)) {
      final shiftBid = _findByShiftRef(shift.shiftRef);
      if (shiftBid == null) {
        _shiftBids.add(ShiftBid(shift: shift));
      } else {
        shiftBid.shift = shift;
      }
    }
  }

  void removeBid(Bid bid) {
    final shiftBid = _findByBidRef(bid.selfRef);
    if (shiftBid != null) {
      shiftBid.bid = null;
      removeShiftBidIfEmpty(shiftBid);
    }
  }

  void modifyShift(Shift shift) {
    addShift(shift);
  }

  void modifyBid(Bid bid) {
    // FIXME wenn sich bid.shiftref ändert, dann muss das entsprechend berücksichtigt werden
    // eventuell bid via bidRef vorher entfernen
    addBid(bid);
  }

  void removeShift(Shift shift) {
    final shiftBid = _findByShiftRef(shift.shiftRef);
    if (shiftBid != null) {
      shiftBid.shift = null;
      removeShiftBidIfEmpty(shiftBid);
    }
  }

  ShiftBid _findByShiftRef(DocumentReference shiftRef) {
    return _shiftBids.firstWhere((shiftBid) => shiftBid.shiftRef == shiftRef,
        orElse: () => null);
  }

  ShiftBid _findByBidRef(DocumentReference bidRef) {
    return _shiftBids.firstWhere(
        (shiftBid) => shiftBid.bid != null && shiftBid.bid.selfRef == bidRef,
        orElse: () => null);
  }

  void removeShiftBidIfEmpty(ShiftBid shiftBid) {
    if (!shiftBid.hasBid() && !shiftBid.hasShift()) {
      _shiftBids.remove(shiftBid);
    }
  }

  void addRejection(Rejection rejection) {
    print("add rejection ${rejection.shiftRef}");

    // TODO find better solution
    rejectedShifts.add(rejection.shiftRef);
    final shiftBid = _findByShiftRef(rejection.shiftRef);
    print("shift: $shiftBid");
    if (shiftBid != null) {
      _shiftBids.remove(shiftBid);
    }
  }
}
