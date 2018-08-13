import 'dart:async';

import 'package:blaulichtplaner_app/bid/vote.dart';
import 'package:blaulichtplaner_app/bid/shift_vote.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

enum FilterOptions { withoutBid, withBid, notInterested }

class ShiftBidsView extends StatefulWidget {
  final List<Role> workAreaRoles;
  final List<Role> employeeRoles;
  final FilterOptions filter;
  final DateTime selectedDate;

  ShiftBidsView(
      {Key key,
      @required this.workAreaRoles,
      @required this.employeeRoles,
      @required this.filter,
      this.selectedDate});

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
  final ShiftVoteHolder _shiftVoteHolder = ShiftVoteHolder();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initOwnVotes();
    _initWorkAreaShifts();
    setState(() {
      _initialized = true;
    });
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
              if (doc.type == DocumentChangeType.added) {
                _shiftVoteHolder.addShift(Shift.fromSnapshot(doc.document));
              } else if (doc.type == DocumentChangeType.modified) {
                _shiftVoteHolder.modifyShift(Shift.fromSnapshot(doc.document));
              } else if (doc.type == DocumentChangeType.removed) {
                _shiftVoteHolder.removeShift(Shift.fromSnapshot(doc.document));
              }
            }
          });
        }));
      }
    }
  }

  void _initOwnVotes() {
    final firestore = Firestore.instance;
    if (widget.employeeRoles != null && widget.employeeRoles.isNotEmpty) {
      for (final role in widget.employeeRoles) {
        final queryStream = firestore
            .collection("shiftVotes")
            .where("employeeRef", isEqualTo: role.reference)
            .where("from", isGreaterThanOrEqualTo: DateTime.now())
            .snapshots();
        subs.add(queryStream.listen((snapshot) {
          setState(() {
            for (final doc in snapshot.documentChanges) {
              if (doc.type == DocumentChangeType.added) {
                _shiftVoteHolder.addVoteFromSnapshot(doc.document);
              } else if (doc.type == DocumentChangeType.modified) {
                _shiftVoteHolder.modifyVoteFromSnapshot(doc.document);
              } else if (doc.type == DocumentChangeType.removed) {
                _shiftVoteHolder.removeVoteFromSnapshot(doc.document);
              }
            }
          });
        }));
      }
    }
  }

  @override
  void didUpdateWidget(ShiftBidsView oldWidget) {
    _initialized = false;
    super.didUpdateWidget(oldWidget);
    for (final sub in subs) {
      sub.cancel();
    }
    subs.clear();
    _shiftVoteHolder.clear();
    _initWorkAreaShifts();
    _initOwnVotes();
    _initialized = true;
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
    ShiftVote shiftVote = _shiftVoteHolder.filterShiftVotes(
        widget.filter, widget.selectedDate)[index];

    final dateFormatter = DateFormat.EEEE("de_DE").add_yMd();
    final timeFormatter = DateFormat.Hm("de_DE");

    String dateTimeLabel = dateFormatter.format(shiftVote.from);

    final shiftDuration = shiftVote.to.difference(shiftVote.from);
    int shiftHours = shiftDuration.inHours;
    final minutesDuration = shiftDuration - Duration(hours: shiftHours);
    int shiftMinutes = minutesDuration.inMinutes;

    String shiftDurationLabel = shiftHours.toString() +
        "h" +
        (shiftMinutes > 0 ? (" " + shiftMinutes.toString() + "m") : "");

    String timeTimeLabel = timeFormatter.format(shiftVote.from) +
        " - " +
        timeFormatter.format(shiftVote.to) +
        " (" +
        shiftDurationLabel +
        ")";

    List<FlatButton> buttons = [];
    if (shiftVote.hasBid()) {
      buttons.add(FlatButton(
        child: Text('Bewerbung löschen'),
        onPressed: () async {
          try {
            await VoteService().delete(shiftVote.vote);
          } catch (e) {
            print(e);
          }
        },
      ));
    } else if (shiftVote.hasRejection()) {
      buttons.add(FlatButton(
        child: Text('Ablehnung löschen'),
        onPressed: () async {
          try {
            await VoteService().delete(shiftVote.vote);
          } catch (e) {
            print(e);
          }
        },
      ));
    } else {
      buttons.add(FlatButton(
        textColor: Colors.red,
        child: Text('Ablehnen'),
        onPressed: () async {
          final role = UserManager
              .get()
              .getRoleForTypeAndReference("employee", shiftVote.shiftplanRef);
          if (role != null) {
            print(await VoteService()
                .save(Rejection.fromShift(shiftVote.shift, role)));
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Sie können sich nicht bewerben.'),
                ));
          }
        },
      ));
      buttons.add(FlatButton(
        child: Text('Bewerben'),
        onPressed: () async {
          final role = UserManager
              .get()
              .getRoleForTypeAndReference("employee", shiftVote.shiftplanRef);
          if (role != null) {
            print(
                await VoteService().save(Bid.fromShift(shiftVote.shift, role)));
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Sie können sich nicht bewerben.'),
                ));
          }
        },
      ));
    }

    List<Widget> rows = <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(shiftVote.workAreaLabel)),
            Expanded(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(shiftVote.locationLabel)),
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

    if (shiftVote.hasShift() && isNotEmpty(shiftVote.shift.publicNote)) {
      rows.add(createInfoBox(shiftVote.shift.publicNote, Icons.assignment));
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
      if ((_shiftVoteHolder
          .filterShiftVotes(widget.filter, widget.selectedDate)
          .isEmpty)) {
        return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                children: <Widget>[
                  _initialized
                      ? Text('Keine Items')
                      : CircularProgressIndicator()
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ));
      } else {
        return ListView.builder(
            itemCount: _shiftVoteHolder
                .filterShiftVotes(widget.filter, widget.selectedDate)
                .length,
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
