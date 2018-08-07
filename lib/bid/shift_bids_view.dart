import 'dart:async';

import 'package:blaulichtplaner_app/bid/bid_editor.dart';
import 'package:blaulichtplaner_app/bid/bid_service.dart';
import 'package:blaulichtplaner_app/bid/rejection.dart';
import 'package:blaulichtplaner_app/bid/shift_bids.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ShiftBidsView extends StatefulWidget {
  final List<Role> workAreaRoles;
  final List<Role> employeeRoles;

  ShiftBidsView(
      {Key key, @required this.workAreaRoles, @required this.employeeRoles});

  bool hasWorkAreaRoles() {
    return workAreaRoles != null && workAreaRoles.isNotEmpty;
  }

  @override
  ShiftBidsViewState createState() {
    return ShiftBidsViewState();
  }
}

class ShiftBidsViewState extends State<ShiftBidsView> {
  final List<StreamSubscription> subs = [];
  final ShiftBidHolder _shiftBidHolder = ShiftBidHolder();

  @override
  void initState() {
    super.initState();
    _initOwnRejections();
    _initWorkAreaShifts();
    _initOwnBids();
  }

  void _initWorkAreaShifts() {
    final firestore = Firestore.instance;
    if (widget.hasWorkAreaRoles()) {
      for (final role in widget.workAreaRoles) {
        final queryStream = firestore
            .collection("shifts")
            .where("workAreaRef", isEqualTo: role.reference)
            .where("acceptBid", isEqualTo: true)
            .where("from", isGreaterThanOrEqualTo: DateTime.now())
            .snapshots();
        subs.add(queryStream.listen((snapshot) {
          setState(() {
            for (final doc in snapshot.documentChanges) {
              Shift shift = Shift.fromSnapshot(doc.document);
              if (doc.type == DocumentChangeType.added) {
                _shiftBidHolder.addShift(shift);
              } else if (doc.type == DocumentChangeType.modified) {
                _shiftBidHolder.modifyShift(shift);
              } else if (doc.type == DocumentChangeType.removed) {
                _shiftBidHolder.removeShift(shift);
              }
            }
          });
        }));
      }
    }
  }

  void _initOwnBids() {
    final firestore = Firestore.instance;
    if (widget.employeeRoles != null && widget.employeeRoles.isNotEmpty) {
      for (final role in widget.employeeRoles) {
        final queryStream = firestore
            .collection("bids")
            .where("employeeRef", isEqualTo: role.reference)
            .where("from", isGreaterThanOrEqualTo: DateTime.now())
            .snapshots();
        subs.add(queryStream.listen((snapshot) {
          setState(() {
            for (final doc in snapshot.documentChanges) {
              if (doc.type == DocumentChangeType.added) {
                _shiftBidHolder.addBid(Bid.fromSnapshot(doc.document));
              } else if (doc.type == DocumentChangeType.modified) {
                // TODO
              } else if (doc.type == DocumentChangeType.removed) {
                _shiftBidHolder.removeBid(Bid.fromSnapshot(doc.document));
              }
            }
          });
        }));
      }
    }
  }

  void _initOwnRejections() {
    final firestore = Firestore.instance;
    if (widget.employeeRoles != null && widget.employeeRoles.isNotEmpty) {
      for (final role in widget.employeeRoles) {
        final queryStream = firestore
            .collection("rejections")
            .where("employeeRef", isEqualTo: role.reference)
            .where("from", isGreaterThanOrEqualTo: DateTime.now())
            .snapshots();
        subs.add(queryStream.listen((snapshot) {
          setState(() {
            for (final doc in snapshot.documentChanges) {
              Rejection rejection = Rejection.fromSnapshot(doc.document);
              if (doc.type == DocumentChangeType.added) {
                _shiftBidHolder.addRejection(rejection);
              } else if (doc.type == DocumentChangeType.modified) {
              } else if (doc.type == DocumentChangeType.removed) {
              }
            }
          });
        }));
      }
    }
  }

  @override
  void didUpdateWidget(ShiftBidsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final sub in subs) {
      sub.cancel();
    }
    subs.clear();
    _shiftBidHolder.clear();
    _initWorkAreaShifts();
    _initOwnBids();
  }

  @override
  void dispose() {
    super.dispose();
    for (final sub in subs) {
      sub.cancel();
    }
  }

  Widget createInfoBox(String text, IconData iconData) {
    return Padding(
        padding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              iconData,
              size: 24.0,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  text,
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _listElementBuilder(BuildContext context, int index) {
    ShiftBid shiftBid = _shiftBidHolder[index];
    final dateFormatter = DateFormat.EEEE("de_DE").add_yMd();
    final timeFormatter = DateFormat.Hm("de_DE");

    String dateTimeLabel = dateFormatter.format(shiftBid.from);

    final shiftDuration = shiftBid.to.difference(shiftBid.from);
    int shiftHours = shiftDuration.inHours;
    final minutesDuration = shiftDuration - Duration(hours: shiftHours);
    int shiftMinutes = minutesDuration.inMinutes;

    String shiftDurationLabel = shiftHours.toString() +
        "h" +
        (shiftMinutes > 0 ? (" " + shiftMinutes.toString() + "m") : "");

    String timeTimeLabel = timeFormatter.format(shiftBid.from) +
        " - " +
        timeFormatter.format(shiftBid.to) +
        " (" +
        shiftDurationLabel +
        ")";

    List<FlatButton> buttons = [];
    if (shiftBid.hasBid()) {
      buttons.add(FlatButton(
        child: Text('Bewerbung löschen'),
        onPressed: () {
          BidService().deleteBid(shiftBid.bid);
        },
      ));
      buttons.add(FlatButton(
        child: Text('Ändern'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BidEditor(
              shiftBid: shiftBid,
            );
          }));
        },
      ));
    } else {
      buttons.add(FlatButton(
        textColor: Colors.red,
        child: Text('Ablehnen'),
        onPressed: () {
          final role = UserManager
              .get()
              .getRoleForTypeAndReference("employee", shiftBid.shiftplanRef);
          if (role != null) {
            Rejection rejection =
                Rejection.fromShift(shiftBid.shift, role.reference);
            rejectShift(rejection);
          }
        },
      ));
      buttons.add(FlatButton(
        child: Text('Bewerben'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BidEditor(
              shiftBid: shiftBid,
            );
          }));
        },
      ));
    }

    List<Widget> rows = <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(shiftBid.workAreaLabel)),
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
      )
    ];

    if (shiftBid.hasShift() && isNotEmpty(shiftBid.shift.publicNote)) {
      rows.add(createInfoBox(shiftBid.shift.publicNote, Icons.assignment));
    }

    if (shiftBid.hasBid() && isNotEmpty(shiftBid.bid.remarks)) {
      rows.add(createInfoBox(shiftBid.bid.remarks, Icons.speaker_notes));
    }

    rows.add(ButtonTheme.bar(
      // make buttons use the appropriate styles for cards
      child: ButtonBar(
        children: buttons,
      ),
    ));

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasWorkAreaRoles()) {
      if (_shiftBidHolder.isEmpty) {
        return Center(
          child: Column(
            children: <Widget>[Text("Keine offene Schichten verfügbar")],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );
      } else {
        return ListView.builder(
            itemCount: _shiftBidHolder.length,
            itemBuilder: _listElementBuilder);
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
