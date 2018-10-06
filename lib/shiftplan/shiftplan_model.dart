import 'package:blaulichtplaner_app/shift_vote/shift_vote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftplanModel {
  DateTime from;
  DateTime to;
  String status;
  String label;
  String companyLabel;
  DocumentReference selfRef;

  ShiftplanModel.fromSnapshot(DocumentSnapshot snapshot, this.companyLabel) {
    selfRef = snapshot.reference;
    from = snapshot.data["from"];
    to = snapshot.data["from"];
    status = snapshot.data["status"];
    label = snapshot.data["label"];
  }
}

class ShiftplanHolder {
  List<ShiftplanModel> _plans = <ShiftplanModel>[];

  void add(ShiftplanModel plan) {
    _plans.add(plan);
    _plans.sort((ShiftplanModel a, ShiftplanModel b) => a.to.compareTo(b.to));
  }

  void modify(ShiftplanModel plan) {
    int index =
        _plans.indexWhere((ShiftplanModel old) => old.selfRef == plan.selfRef);
    if (index >= 0) {
      _plans[index] = plan;
    }
    _plans.sort((ShiftplanModel a, ShiftplanModel b) => a.to.compareTo(b.to));
  }

  void remove(ShiftplanModel plan) {
    int index =
        _plans.indexWhere((ShiftplanModel old) => old.selfRef == plan.selfRef);
    if (index >= 0) {
      _plans.removeAt(index);
    }
  }

  get isEmpty => _plans.isEmpty;

  void clear() {
    _plans.clear();
  }

  List<ShiftplanModel> get plans => _plans;
}

class ShiftHolder {
  List<Shift> _shifts = <Shift>[];

  void add(Shift shift) {
    _shifts.add(shift);
    _shifts.sort((Shift a, Shift b) => a.to.compareTo(b.to));
  }

  void modify(Shift shift) {
    int index =
        _shifts.indexWhere((Shift old) => old.shiftRef == shift.shiftRef);
    if (index >= 0) {
      _shifts[index] = shift;
    }
    _shifts.sort((Shift a, Shift b) => a.to.compareTo(b.to));
  }

  void remove(Shift shift) {
    int index =
        _shifts.indexWhere((Shift old) => old.shiftRef == shift.shiftRef);
    if (index >= 0) {
      _shifts.removeAt(index);
    }
  }

  void clear() {
    _shifts.clear();
  }

  get isEmpty => _shifts.isEmpty;

  List<Shift> get shifts => _shifts;

  List<Shift> getShiftsBetween(DateTime from, DateTime to) {
    return _shifts
        .where((Shift a) =>
            (a.from.isAfter(from) || a.from.isAtSameMomentAs(from)) &&
            (a.from.isBefore(to) || a.from.isAtSameMomentAs(to)))
        .toList();
  }
}
