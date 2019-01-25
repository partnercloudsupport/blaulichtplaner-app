import 'dart:async';

import 'package:blaulichtplaner_app/shift_vote/vote.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_vote.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/utils/utils.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';

enum FilterOptions { allShifts, withoutBid, withBid, notInterested }

class ShiftVotesView extends StatefulWidget {
  final List<Role> employeeRoles;
  final FilterOptions filter;
  final DateTime selectedDate;

  ShiftVotesView({
    Key key,
    @required this.employeeRoles,
    @required this.filter,
    this.selectedDate,
  });

  bool hasEmployeeRoles() {
    return employeeRoles != null && employeeRoles.isNotEmpty;
  }

  @override
  ShiftVotesViewState createState() {
    return ShiftVotesViewState();
  }
}

class ShiftVotesViewState extends State<ShiftVotesView> {
  final List<StreamSubscription> subs = [];
  final ShiftVoteHolder _shiftVoteHolder = ShiftVoteHolder();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initDataListeners();
  }

  void _initDataListeners() {
    final firestore = Firestore.instance;
    if (widget.hasEmployeeRoles()) {
      for (final role in widget.employeeRoles) {
        final votesQueryStream = firestore
            .collection("shiftVotes")
            .where("employeeRef", isEqualTo: role.employeeRef)
            .where("from", isGreaterThanOrEqualTo: DateTime.now())
            .snapshots();
        subs.add(votesQueryStream.listen((snapshot) {
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
        final queryStream = firestore
            .collection("shifts")
            .where("companyRef", isEqualTo: role.reference)
            .where("acceptBid", isEqualTo: true)
            .where("manned", isEqualTo: false)
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
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void didUpdateWidget(ShiftVotesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _initialized = false;
    });
    for (final sub in subs) {
      sub.cancel();
    }
    subs.clear();
    _shiftVoteHolder.clear();
    _initDataListeners();
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

    String dateTimeLabel = dateFormatter.format(shiftVote.from?.toDate());

    final shiftDuration = shiftVote.shiftDuration();
    int shiftHours = shiftDuration.inHours;
    final minutesDuration = shiftDuration - Duration(hours: shiftHours);
    int shiftMinutes = minutesDuration.inMinutes;

    String shiftDurationLabel = shiftHours.toString() +
        "h" +
        (shiftMinutes > 0 ? (" " + shiftMinutes.toString() + "m") : "");

    String timeTimeLabel = timeFormatter.format(shiftVote.from?.toDate()) +
        " - " +
        timeFormatter.format(shiftVote.to?.toDate()) +
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
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Bewerbung gelöscht.'),
            ));
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
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Ablehnung gelöscht.'),
            ));
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
          final role = UserManager.get()
              .getRoleForTypeAndReference("employee", shiftVote.shiftplanRef);
          if (role != null) {
            await VoteService()
                .save(Rejection.fromShift(shiftVote.shift, role));
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Ablehnung gespeichert.'),
            ));
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
          final role = UserManager.get()
              .getRoleForTypeAndReference("employee", shiftVote.shiftplanRef);
          if (role != null) {
            await VoteService().save(Bid.fromShift(shiftVote.shift, role));
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Bewerbung gespeichert.'),
            ));
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Sie können sich nicht bewerben.'),
            ));
          }
        },
      ));
    }

    IconData icon = Icons.help;
    Color color = Colors.grey;
    if (shiftVote.hasBid()) {
      icon = Icons.check;
      color = Colors.green;
    } else if (shiftVote.hasRejection()) {
      icon = Icons.close;
      color = Colors.red;
    }
    List<Widget> rows = <Widget>[
      ListTile(
        title: Text(dateTimeLabel),
        subtitle: Text(timeTimeLabel),
        contentPadding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
        trailing: Icon(
          icon,
          color: color,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Wrap(
          children: <Widget>[
            Chip(
              label: Text('${shiftVote.workAreaLabel}'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Chip(
                label: Text('${shiftVote.locationLabel}'),
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

  _fallbackText() {
    switch (widget.filter) {
      case FilterOptions.allShifts:
        return 'Keine Schichten verfügbar';
      case FilterOptions.notInterested:
        return 'Keine abgelehnten Schichten';
      case FilterOptions.withBid:
        return 'Keine Schichten mit Bewerbung';
      case FilterOptions.withoutBid:
        return 'Keine offenen Dienste';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasEmployeeRoles()) {
      return LoaderBodyWidget(
        loading: !_initialized,
        child: ListView.builder(
            itemCount: _shiftVoteHolder
                .filterShiftVotes(widget.filter, widget.selectedDate)
                .length,
            itemBuilder: _listElementBuilder),
        fallbackText: _fallbackText(),
        empty: _shiftVoteHolder
            .filterShiftVotes(widget.filter, widget.selectedDate)
            .isEmpty,
      );
    } else {
      return NoEmployee();
    }
  }
}
