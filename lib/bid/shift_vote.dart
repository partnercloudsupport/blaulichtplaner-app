import 'package:blaulichtplaner_app/bid/shift_votes_view.dart';
import 'package:blaulichtplaner_app/bid/vote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftVote {
  Shift shift;
  Vote vote;

  ShiftVote({this.shift, this.vote});

  DateTime get from {
    if (shift != null) {
      return shift.from;
    } else {
      return vote.from;
    }
  }

  DateTime get to {
    if (shift != null) {
      return shift.to;
    } else {
      return vote.to;
    }
  }

  String get workAreaLabel {
    if (shift != null) {
      return shift.workAreaLabel;
    } else {
      return "Unbekannte Abteilung";
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
      return vote.shiftplanRef;
    }
  }

  DocumentReference get shiftRef {
    if (shift != null) {
      return shift.shiftRef;
    } else {
      return vote.shiftRef;
    }
  }

  bool hasShift() => shift != null;

  bool hasBid() => vote != null ? (vote is Bid) : false;
  bool hasRejection() => vote != null ? (vote is Rejection) : false;

  bool hasVote() => vote != null;

  get bid => (vote is Bid) ? vote : null;
  get rejection => (vote is Rejection) ? vote : null;
}

class ShiftVoteHolder {
  final List<ShiftVote> _shiftVotes = <ShiftVote>[];

  int get length => _shiftVotes.length;

  bool get isEmpty => _shiftVotes.isEmpty;

  void clear() {
    _shiftVotes.clear();
  }

  ShiftVote operator [](int index) {
    return _shiftVotes[index];
  }

  void addBid(Bid bid) {
    if (bid.shiftRef != null) {
      final shiftVote = _findByShiftRef(bid.shiftRef);
      if (shiftVote == null) {
        _shiftVotes.add(ShiftVote(vote: bid));
      } else {
        shiftVote.vote = bid;
      }
    } else {
      _shiftVotes.add(ShiftVote(vote: bid));
    }
  }

  void addRejection(Rejection rejection) {
    if (rejection.shiftRef != null) {
      final shiftVote = _findByShiftRef(rejection.shiftRef);
      if (shiftVote == null) {
        _shiftVotes.add(ShiftVote(vote: rejection));
      } else {
        shiftVote.vote = rejection;
      }
    } else {
      _shiftVotes.add(ShiftVote(vote: rejection));
    }
  }

  void addVoteFromSnapshot(DocumentSnapshot document) {
    if (document.data["isBid"]) {
      addBid(Bid.fromSnapshot(document));
    } else {
      addRejection(Rejection.fromSnapshot(document));
    }
  }

  void addShift(Shift shift) {
    final shiftVote = _findByShiftRef(shift.shiftRef);
    if (shiftVote == null) {
      _shiftVotes.add(ShiftVote(shift: shift));
    } else {
      shiftVote.shift = shift;
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

  void modifyRejection(Rejection rejection) {
    addRejection(rejection);
  }

  void modifyVoteFromSnapshot(DocumentSnapshot document) {
    if (document.data["isBid"]) {
      modifyBid(Bid.fromSnapshot(document));
    } else {
      modifyRejection(Rejection.fromSnapshot(document));
    }
  }

  void removeBid(Bid bid) {
    final shiftVote = _findByBidRef(bid.selfRef);
    if (shiftVote != null) {
      shiftVote.vote = null;
      removeShiftVoteIfEmpty(shiftVote);
    }
  }

  void removeShift(Shift shift) {
    final shiftVote = _findByShiftRef(shift.shiftRef);
    if (shiftVote != null) {
      shiftVote.shift = null;
      removeShiftVoteIfEmpty(shiftVote);
    }
  }

  void removeRejection(Rejection rejection) {
    final shiftVote = _findByRejectionRef(rejection.selfRef);
    if (shiftVote != null) {
      shiftVote.vote = null;
      removeShiftVoteIfEmpty(shiftVote);
    }
  }
  void removeVoteFromSnapshot(DocumentSnapshot document) {
    if (document.data["isBid"]) {
      removeBid(Bid.fromSnapshot(document));
    } else {
      removeRejection(Rejection.fromSnapshot(document));
    }
  }

  ShiftVote _findByShiftRef(DocumentReference shiftRef) {
    return _shiftVotes.firstWhere((shiftVote) => shiftVote.shiftRef == shiftRef,
        orElse: () => null);
  }

  ShiftVote _findByBidRef(DocumentReference bidRef) {
    return _shiftVotes.firstWhere(
        (shiftVote) => shiftVote.bid != null && shiftVote.bid.selfRef == bidRef,
        orElse: () => null);
  }

  ShiftVote _findByRejectionRef(DocumentReference rejectionRef) {
    return _shiftVotes.firstWhere(
        (shiftVote) =>
            shiftVote.rejection != null && shiftVote.rejection == rejectionRef,
        orElse: () => null);
  }

  Function _filterDate(DateTime selectedDate) {
    return (ShiftVote shiftVote) {
      if (selectedDate != null) {
        return (shiftVote.shift.from.day == selectedDate.day) &&
            (shiftVote.shift.from.month == selectedDate.month) &&
            (shiftVote.shift.from.year == selectedDate.year);
      } else {
        return true;
      }
    };
  }

  List<ShiftVote> filterShiftVotes(
      FilterOptions option, DateTime selectedDate) {
    switch (option) {
      case FilterOptions.withoutBid:
        return _shiftVotes
            .where((ShiftVote shiftVote) => !shiftVote.hasVote())
            .where(_filterDate(selectedDate))
            .toList();
      case FilterOptions.withBid:
        return _shiftVotes
            .where((ShiftVote shiftVote) => shiftVote.hasBid())
            .where(_filterDate(selectedDate))
            .toList();
      case FilterOptions.notInterested:
        return _shiftVotes
            .where((ShiftVote shiftVote) => shiftVote.hasRejection())
            .where(_filterDate(selectedDate))
            .toList();
      default:
        return null;
    }
  }

  void removeShiftVoteIfEmpty(ShiftVote shiftVote) {
    if (!shiftVote.hasVote() && !shiftVote.hasShift()) {
      _shiftVotes.remove(shiftVote);
    }
  }
}

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
