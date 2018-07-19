import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ShiftView extends StatefulWidget {
  final List<DocumentReference> employeeRefs;

  ShiftView({Key key, @required List<DocumentReference> employeeRefs})
      : employeeRefs = employeeRefs;

  bool hasEmployeeRefs() {
    return employeeRefs != null && employeeRefs.isNotEmpty;
  }

  @override
  ShiftViewState createState() {
    return new ShiftViewState();
  }
}

class Shift {
  String id;
  DateTime from;
  DateTime to;
  String workAreaLabel;

  Shift.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    from = snapshot.data["from"];
    to = snapshot.data["to"];
    workAreaLabel = snapshot.data["workAreaLabel"];
  }
}

class ShiftViewState extends State<ShiftView> {
  final List<Shift> _shifts = [];
  final List<StreamSubscription> subs = [];

  @override
  void initState() {
    super.initState();
    final firestore = Firestore.instance;
    if (widget.hasEmployeeRefs()) {
      print("Listening for assignments: ");
      final queryStream = firestore
          .collection("assignments")
          .where("employeeRef", isEqualTo: widget.employeeRefs.first)
          .snapshots();
      subs.add(queryStream.listen((snapshot) {
        setState(() {
          for (final doc in snapshot.documentChanges) {
            final shiftId = doc.document.documentID;

            if (doc.type == DocumentChangeType.added) {
              _shifts.add(Shift.fromSnapshot(doc.document));
            } else if (doc.type == DocumentChangeType.modified) {
              _shifts.removeWhere((shift) => shift.id == shiftId);
              _shifts.add(Shift.fromSnapshot(doc.document));
            } else if (doc.type == DocumentChangeType.removed) {
              _shifts.removeWhere((shift) => shift.id == shiftId);
            }
          }
          _shifts.sort((s1, s2) => s1.from.compareTo(s2.from));
        });
      }));
    }
  }

  @override
  void didUpdateWidget(ShiftView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO
  }

  @override
  void dispose() {
    super.dispose();
    for (final sub in subs) {
      sub.cancel();
    }
  }

  Widget _shiftBuilder(BuildContext context, int index) {
    Shift shift = _shifts[index];
    final dateFormatter = DateFormat.EEEE("de_DE").add_yMd();
    final timeFormatter = DateFormat.Hm("de_DE");

    String dateTimeLabel = dateFormatter.format(shift.from);

    final shiftDuration = shift.to.difference(shift.from);
    int shiftHours = shiftDuration.inHours;
    final minutesDuration = shiftDuration - Duration(hours: shiftHours);
    int shiftMinutes = minutesDuration.inMinutes;

    String shiftDurationLabel = shiftHours.toString() +
        "h" +
        (shiftMinutes > 0 ? (" " + shiftMinutes.toString() + "m") : "");

    String timeTimeLabel = timeFormatter.format(shift.from) +
        " - " +
        timeFormatter.format(shift.to) +
        " (" +
        shiftDurationLabel +
        ")";

    return new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(shift.workAreaLabel)),
                Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("Gesundbrunnen")),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasEmployeeRefs()) {
      if (_shifts.isEmpty) {
        return new Center(
          child: new Column(
            children: <Widget>[Text("Keine Schichten verfügbar")],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );
      } else {
        return ListView.builder(
            itemCount: _shifts.length, itemBuilder: _shiftBuilder);
      }
    } else {
      return new Center(
        child: new Column(
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
