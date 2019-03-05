import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

class ShiftplanModel {
  DateTime from;
  DateTime to;
  String status;
  String label;
  String locationLabel;
  String companyLabel;
  DocumentReference selfRef;
  DocumentReference employeeRef;

  ShiftplanModel.fromSnapshot(
      DocumentSnapshot snapshot, this.companyLabel, this.employeeRef) {
    selfRef = snapshot.reference;
    from = snapshot.data["from"];
    to = snapshot.data["to"];
    status = snapshot.data["status"];
    locationLabel = snapshot.data["locationLabel"];
    label = snapshot.data["label"];
  }

  DateTime startOfPlan() {
    return from.subtract(Duration(days: from.weekday - 1));
  }

  DateTime endOfPlan() {
    return to.add(Duration(days: 7 - to.weekday));
  }

  String get shiftplanLabel {
    return label ?? "Dienstplan";
  }

  String get title {
    if (companyLabel != null) {
      return companyLabel + " > " + locationLabel;
    } else {
      return locationLabel;
    }
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
  List<EmployeeShift> _shifts = [];

  void add(EmployeeShift shift) {
    _shifts.add(shift);
    _shifts.sort((EmployeeShift a, EmployeeShift b) => a.to.compareTo(b.to));
  }

  void modify(EmployeeShift shift) {
    int index = _shifts
        .indexWhere((EmployeeShift old) => old.shiftRef == shift.shiftRef);
    if (index >= 0) {
      _shifts[index] = shift;
    }
    _shifts.sort((EmployeeShift a, EmployeeShift b) => a.to.compareTo(b.to));
  }

  void remove(EmployeeShift shift) {
    int index = _shifts
        .indexWhere((EmployeeShift old) => old.shiftRef == shift.shiftRef);
    if (index >= 0) {
      _shifts.removeAt(index);
    }
  }

  void clear() {
    _shifts.clear();
  }

  get isEmpty => _shifts.isEmpty;

  List<EmployeeShift> get shifts => _shifts;

  List<EmployeeShift> getShiftsBetween(DateTime from, DateTime to) {
    return _shifts
        .where((EmployeeShift a) => a.isFromBetween(from, to))
        .toList();
  }
}
