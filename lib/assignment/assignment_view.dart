import 'dart:async';

import 'package:blaulichtplaner_app/assignment/assignment_service.dart';
import 'package:blaulichtplaner_app/evaluation/evaluation_editor.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AssignmentView extends StatefulWidget {
  final List<Role> employeeRoles;
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
  final List<Loadable<Assignment>> _assignments = [];
  final List<StreamSubscription> subs = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initDataListeners();
  }

  void _initDataListeners() {
    final firestore = Firestore.instance;
    if (widget.hasEmployeeRoles()) {
      print("Listening for assignments: ${widget.upcomingShifts}");

      for (final role in widget.employeeRoles) {
        Query query = firestore
            .collection("assignments")
            .where("employeeRef", isEqualTo: role.reference);
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
            _initialized = true;
            for (final doc in snapshot.documentChanges) {
              final assignmentRef = doc.document.reference;

              if (doc.type == DocumentChangeType.added) {
                _assignments
                    .add(Loadable(Assignment.fromSnapshot(doc.document)));
              } else if (doc.type == DocumentChangeType.modified) {
                _assignments.removeWhere(
                    (assignment) => assignment.data.selfRef == assignmentRef);
                _assignments
                    .add(Loadable(Assignment.fromSnapshot(doc.document)));
              } else if (doc.type == DocumentChangeType.removed) {
                _assignments.removeWhere(
                    (assignment) => assignment.data.selfRef == assignmentRef);
              }
            }
            _assignments.sort((s1, s2) => s1.data.from.compareTo(s2.data.from));
          });
        }));
      }
    }
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

  Widget _assignmentBuilder(BuildContext context, int index) {
    Loadable loadableAssignment = _assignments[index];
    Assignment assignment = loadableAssignment.data;
    final dateFormatter = DateFormat.EEEE("de_DE").add_yMd();
    final timeFormatter = DateFormat.Hm("de_DE");

    String dateTimeLabel = dateFormatter.format(assignment.from);

    final shiftDuration = assignment.to.difference(assignment.from);
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
      Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(assignment.workAreaLabel)),
            Expanded(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(assignment.locationLabel)),
            )
          ],
        ),
      ),
      ListTile(
        title: Text(dateTimeLabel),
        subtitle: Text(timeTimeLabel),
        contentPadding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
      ),
    ];

    if (assignment.from.isBefore(DateTime.now())) {
      cardChildren.add(LoaderWidget(
          loading: loadableAssignment.loading,
          padding: EdgeInsets.all(14.0),
          child: ButtonTheme.bar(
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  child: Text('Finalisieren'),
                  onPressed: DateTime.now().isAfter(assignment.to)
                      ? () {
                          setState(() {
                            loadableAssignment.loading = true;
                          });
                          AssignmentService.finishAssignment(assignment);
                        }
                      : null,
                ),
                FlatButton(
                  child: Text('Auswertung'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EvaluationEditor(
                        assignment: assignment,
                      );
                    }));
                  },
                ),
              ],
            ),
          )));
    }
    Widget card = Card(
        child: Column(mainAxisSize: MainAxisSize.max, children: cardChildren),
      );
    Widget timeDiff = _timeDiffBuilder(index);
    if (timeDiff != null) {
      return Column(children: <Widget>[timeDiff, card],mainAxisAlignment: MainAxisAlignment.center,);
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
              borderRadius: BorderRadius.circular(28.0)),
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
      if (_initialized) {
        if (_assignments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(
                    widget.upcomingShifts
                        ? "Keine zugewiesenen Schichten verfügbar"
                        : "Keine Schichten vorhanden, die eine Auswertung benötigen",
                    textAlign: TextAlign.center,
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          );
        } else {
          return ListView.builder(
            itemBuilder: _assignmentBuilder,
            itemCount: _assignments.length,
          );
        }
      } else {
        return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                children: <Widget>[CircularProgressIndicator()],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ));
      }
    } else {
      return Center(
        child: Column(
          children: <Widget>[
            Text(
                "Sie sind noch an keinem Standort als Mitarbeiter registriert.")
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      );
    }
  }
}
