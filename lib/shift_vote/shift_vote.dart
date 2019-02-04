import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
/*

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

  Duration shiftDuration() {
    return to.difference(from);
  }

  bool hasShift() => shift != null;

  bool hasBid() => vote != null ? (vote.isBid) : false;
  bool hasRejection() => vote != null ? (!vote.isBid) : false;

  bool hasVote() => vote != null;

  get bid => (vote.isBid) ? vote : null;
  get rejection => (!vote.isBid) ? vote : null;
}
*/
/*
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
        return (shiftVote.shift.isFromEqual(selectedDate));
      } else {
        return true;
      }
    };
  }

  List<ShiftVote> filterShiftVotes(
      FilterOptions option, DateTime selectedDate) {
    List<ShiftVote> filteredShiftVotes = <ShiftVote>[];
    switch (option) {
      case FilterOptions.allShifts:
        filteredShiftVotes = _shiftVotes;
        break;
      case FilterOptions.withoutBid:
        filteredShiftVotes = _shiftVotes
            .where((ShiftVote shiftVote) =>
                !shiftVote.hasVote() && shiftVote.shift.status == 'public')
            .toList();
        break;
      case FilterOptions.withBid:
        filteredShiftVotes = _shiftVotes
            .where((ShiftVote shiftVote) => shiftVote.hasBid())
            .toList();
        break;
      case FilterOptions.notInterested:
        filteredShiftVotes = _shiftVotes
            .where((ShiftVote shiftVote) => shiftVote.hasRejection())
            .toList();
        break;
      default:
        return null;
        break;
    }
    return filteredShiftVotes
        .where((ShiftVote shiftVote) =>
            UserManager.get().getRoleForTypeAndReference(
                "employee", shiftVote.shiftplanRef) !=
            null)
        .where(_filterDate(selectedDate))
        .toList();
  }

  void removeShiftVoteIfEmpty(ShiftVote shiftVote) {
    if (!shiftVote.hasVote() && !shiftVote.hasShift()) {
      _shiftVotes.remove(shiftVote);
    }
  }
}
*/
