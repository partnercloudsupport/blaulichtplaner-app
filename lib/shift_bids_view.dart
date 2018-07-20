import 'dart:async';

import 'package:blaulichtplaner_app/bid_editor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ShiftBidsView extends StatefulWidget {
  final List<DocumentReference> workAreaRefs;

  ShiftBidsView({Key key, @required this.workAreaRefs});

  bool hasWorkAreaRefs() {
    return workAreaRefs != null && workAreaRefs.isNotEmpty;
  }

  @override
  ShiftBidsViewState createState() {
    return new ShiftBidsViewState();
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

class ShiftBidsViewState extends State<ShiftBidsView> {
  final List<Shift> _shifts = [];
  final List<StreamSubscription> subs = [];

  @override
  void initState() {
    super.initState();
    final firestore = Firestore.instance;
    if (widget.hasWorkAreaRefs()) {
      print("Listening for bids: ${widget.workAreaRefs.first.path}");
      final queryStream = firestore
          .collection("shifts")
          .where("workAreaRef", isEqualTo: widget.workAreaRefs.first)
          .where("acceptBid", isEqualTo: true)
          .snapshots();
      subs.add(queryStream.listen((snapshot) {
        setState(() {
          for (final doc in snapshot.documentChanges) {
            if (doc.type == DocumentChangeType.added) {
              _shifts.add(Shift.fromSnapshot(doc.document));
            } else if (doc.type == DocumentChangeType.modified) {
              // TODO
            } else if (doc.type == DocumentChangeType.removed) {
              // TODO
            }
          }
        });
      }));
    }
  }

  @override
  void didUpdateWidget(ShiftBidsView oldWidget) {
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
          new ButtonTheme.bar(
            // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: Text('Bewerben'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return new BidEditor();
                    }));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasWorkAreaRefs()) {
      if (_shifts.isEmpty) {
        return new Center(
          child: new Column(
            children: <Widget>[Text("Keine offene Schichten verfügbar")],
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
