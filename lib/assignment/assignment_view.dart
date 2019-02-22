import 'dart:async';

import 'package:blaulichtplaner_app/assignment/assignment_botton_bar.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/shift/shift_view.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AssignmentView extends StatefulWidget {
  final List<UserRole> employeeRoles;
  final bool upcomingShifts;

  AssignmentView(
      {Key key, @required this.employeeRoles, @required this.upcomingShifts});

  bool hasEmployeeRoles() {
    return employeeRoles != null && employeeRoles.isNotEmpty;
  }

  @override
  AssignmentViewState createState() {
    return AssignmentViewState();
  }
}

class AssignmentViewState extends State<AssignmentView> {
  final List<Loadable<AssignmentModel>> _assignments = [];
  final List<StreamSubscription> subs = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initDataListeners();
  }

  @override
  void didUpdateWidget(AssignmentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cancelDataListeners();
    _assignments.clear();
    _initDataListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelDataListeners();
  }

  void _cancelDataListeners() {
    for (final sub in subs) {
      sub.cancel();
    }
  }

  void _initDataListeners() {
    final firestore = FirestoreImpl.instance;
    if (widget.hasEmployeeRoles()) {
      for (final role in widget.employeeRoles) {
        Query query = firestore
            .collection("assignments")
            .where("status", isEqualTo: "public")
            .where("employeeRef", isEqualTo: role.employeeRef);
        if (widget.upcomingShifts) {
          query = query
              .where("to", isGreaterThanOrEqualTo: DateTime.now())
              .orderBy("to");
        } else {
          query = query
              .where("evaluated", isEqualTo: false)
              .where("to", isLessThanOrEqualTo: DateTime.now())
              .orderBy("to", descending: true);
        }

        subs.add(query.snapshots().listen((snapshot) {
          setState(() {
            for (final doc in snapshot.documentChanges) {
              final assignmentRef = doc.document.reference;

              if (doc.type == DocumentChangeType.added) {
                _assignments
                    .add(Loadable(AssignmentModel.fromSnapshot(doc.document)));
              } else if (doc.type == DocumentChangeType.modified) {
                _assignments.removeWhere(
                    (assignment) => assignment.data.selfRef == assignmentRef);
                _assignments
                    .add(Loadable(AssignmentModel.fromSnapshot(doc.document)));
              } else if (doc.type == DocumentChangeType.removed) {
                _assignments.removeWhere(
                    (assignment) => assignment.data.selfRef == assignmentRef);
              }
            }
            _assignments.sort((s1, s2) => s1.data.from.compareTo(s2.data.from));

            _initialized = true;
          });
        }));
      }
    }
  }

  void _finishEvaluation(Loadable<AssignmentModel> loadableAssignment) async {
    setState(() {
      loadableAssignment.loading = true;
    });
    await finishEvaluation(loadableAssignment.data, FirestoreImpl.instance);
    // TODO update all data???
  }

  Widget _assignmentBuilder(BuildContext context, int index) {
    Loadable loadableAssignment = _assignments[index];
    AssignmentModel assignment = loadableAssignment.data;
    AssignmentStatus assignmentStatus = AssignmentStatus(assignment);

    final dateFormatter = DateFormat("EEEE',' ","de_DE").add_yMd();
    final timeFormatter = DateFormat.Hm("de_DE");

    String dateTimeLabel = dateFormatter.format(assignment.from);

    final shiftDuration = assignment.toFromDifference();
    int shiftHours = shiftDuration.inHours;
    final minutesDuration = shiftDuration - Duration(hours: shiftHours);
    int shiftMinutes = minutesDuration.inMinutes;

    String shiftDurationLabel = shiftHours.toString() +
        "h" +
        (shiftMinutes > 0 ? (" " + shiftMinutes.toString() + "m") : "");

    String timeTimeLabel = timeFormatter.format(assignment.from) +
        " - " +
        timeFormatter.format(assignment.to) +
        " (" +
        shiftDurationLabel +
        ")";

    List<Widget> cardChildren = [
      ListTile(
        title: Text(dateTimeLabel),
        subtitle: Text(timeTimeLabel),
        contentPadding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
      ),
      Padding(
        padding: EdgeInsets.only(
            left: 16.0, bottom: assignmentStatus.started ? 0 : 8),
        child: Wrap(
          children: <Widget>[
            Chip(
              label: Text('${assignment.workAreaLabel}'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Chip(
                label: Text('${assignment.locationLabel}'),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.black.withAlpha(0x1f),
                        width: 1.0,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(28.0)),
              ),
            ),
          ],
        ),
      ),
    ];

    if (assignmentStatus.started) {
      cardChildren.add(AssignmentButtonBar(
        loadableAssignment: loadableAssignment,
        finishCallback: assignmentStatus.canBeFinished
            ? () {
                _finishEvaluation(loadableAssignment);
              }
            : null,
      ));
    }
    if (assignmentStatus.showNotFinishableWarning) {
      cardChildren.add(Padding(
        padding: EdgeInsets.only(left: 14, right: 14, bottom: 8),
        child: Text(
          "Die Schicht ist noch nicht abgeschlossen und kann nicht finalisiert werden.",
          style: TextStyle(color: Colors.redAccent),
        ),
      ));
    }
    Widget card = Card(
        child: InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return ShiftViewWidget(
            shiftRef: assignment.shiftRef,
            currentEmployeeRef: assignment.employeeRef,
          );
        }));
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardChildren,
      ),
    ));
    Widget timeDiff = _timeDiffBuilder(index);
    if (timeDiff != null) {
      return Column(
        children: <Widget>[timeDiff, card],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      return card;
    }
  }

  _timeDiffBuilder(int index) {
    if (index == 0) {
      return null;
    }
    DateTime from = _assignments[index - 1].data.to;
    DateTime to = _assignments[index].data.from;
    Duration diff = to.difference(from);
    if (diff.inMinutes > 0) {
      String label = "";
      if (diff.inHours > 1) {
        if (diff.inDays > 1) {
          label = '${diff.inDays} Tage frei';
        } else {
          label = '${diff.inHours} Stunden frei';
        }
      } else {
        label = '${diff.inMinutes} Minuten frei';
      }
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: Chip(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Colors.black.withAlpha(0x1f),
                width: 1.0,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(28.0),
          ),
          label: Text(label),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasEmployeeRoles()) {
      return LoaderBodyWidget(
        loading: !_initialized,
        child: ListView.builder(
          itemBuilder: _assignmentBuilder,
          itemCount: _assignments.length,
        ),
        empty: _assignments.isEmpty,
        fallbackText: widget.upcomingShifts
            ? "Sie haben keine zugewiesenen Schichten!"
            : "Keine Schichten vorhanden, die eine Auswertung benötigen!",
      );
    } else {
      return NoEmployee();
    }
  }
}
