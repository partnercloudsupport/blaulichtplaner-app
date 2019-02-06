import 'dart:async';
import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote_editor.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote_service.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';

class LocationVotesView extends StatefulWidget {
  final List<UserRole> employeeRoles;
  LocationVotesView({Key key, @required this.employeeRoles}) : super(key: key);
  bool hasEmployeeRoles() {
    return employeeRoles != null && employeeRoles.isNotEmpty;
  }

  @override
  State<StatefulWidget> createState() {
    return LocationVotesViewState();
  }
}

class LocationVotesViewState extends State<LocationVotesView> {
  bool _initialized = false;
  UserVoteHolder _userVoteHolder;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _userVoteHolder = UserVoteHolder();
    _initLocationVotes();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  void _initLocationVotes() {
    BlpUser user = UserManager.instance.user;

    Stream<QuerySnapshot> stream = FirestoreImpl.instance
        .collection('users')
        .document(user.uid)
        .collection('votes')
        .snapshots();
    _subscription = stream.listen((snapshot) {
      setState(() {
        for (final doc in snapshot.documentChanges) {
          if (doc.type == DocumentChangeType.added) {
            _userVoteHolder.add(UserVote.fromSnapshot(doc.document));
          } else if (doc.type == DocumentChangeType.modified) {
            _userVoteHolder.modify(UserVote.fromSnapshot(doc.document));
          } else if (doc.type == DocumentChangeType.removed) {
            _userVoteHolder.remove(UserVote.fromSnapshot(doc.document));
          }
        }
        _initialized = true;
      });
    });
  }

  Widget _createLocationTile(UserVote userVote) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Wrap(
        children: userVote.locations
            .map((UserVoteLocationItem location) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.black.withAlpha(0x1f),
                            width: 1.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(28.0)),
                    label: Text(location.locationLabel),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    BlpUser user = UserManager.instance.user;

    UserVote userVote = _userVoteHolder.userVotes[index];
    String from = DateFormat.yMd("de_DE").format(userVote.from);
    String to = DateFormat.yMd("de_DE").format(userVote.to);
    String fromToLabel = "Zeitraum $from bis $to";
    int minHours = userVote.minHours;
    int maxHours = userVote.maxHours;
    String hoursLabel = "min. $minHours Stunden - max. $maxHours Stunden";
    List<Widget> rows = <Widget>[
      ListTile(
        title: Text(fromToLabel),
        subtitle: Text(hoursLabel),
      ),
      _createLocationTile(userVote),
      ButtonTheme.bar(
        child: ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text(
                'Löschen',
              ),
              onPressed: () async {
                userVote.databaseOperation = DatabaseOperation.deleteData;
                await UserVoteService().save(userVote, user);
              },
              textColor: Colors.red,
            ),
            FlatButton(
              child: Text('Bearbeiten'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LocationVoteEditor(
                          employeeRoles: widget.employeeRoles,
                          userVote: userVote,
                        ),
                  ),
                );
              },
              textColor: Colors.blue,
            ),
          ],
        ),
      ),
    ];

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
    if (widget.hasEmployeeRoles()) {
      return LoaderBodyWidget(
        child: ListView.builder(
          itemBuilder: _itemBuilder,
          itemCount: _userVoteHolder.userVotes.length,
        ),
        loading: !_initialized,
        fallbackText:
            'Keine Bewerbungen.\nFügen Sie neue mit dem + Symbol hinzu',
        empty: _userVoteHolder.isEmpty,
      );
    } else {
      return NoEmployee();
    }
  }
}
