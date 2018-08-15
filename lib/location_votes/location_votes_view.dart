import 'dart:async';
import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote_editor.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocationVotesView extends StatefulWidget {
  final List<Role> employeeRoles;
  LocationVotesView({Key key, @required this.employeeRoles}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationVotesViewState();
  }
}

class LocationVotesViewState extends State<LocationVotesView> {
  bool _initialized = false;
  //StreamSubscription _subscription;
  List<UserVote> userVotes;

  @override
  void initState() {
    super.initState();
    userVotes = List();
    UserVote vote = UserVote()
      ..from = DateTime.now()
      ..to = DateTime.now().add(Duration(days: 40))
      ..minHours = 12
      ..maxHours = 24
      ..remarks = "Blub";
    userVotes.add(vote);
    setState(() {
      _initialized = true;
    });
  }

/*
  void _initLocationVotes() {
    final firestore = Firestore.instance;
    final FirebaseUser user = UserManager.get().user;

    final queryStream = firestore
        .collection('users')
        .document(user.uid)
        .collection('collectionPath')
        .snapshots();
    _subscription = queryStream.listen((snapshot) {
      setState(() {
   
       
        for (final doc in snapshot.documentChanges) {
          if (doc.type == DocumentChangeType.added) {
            userVotes.add(UserVote.fromSnapshot(doc.document));
          } else if (doc.type == DocumentChangeType.modified) {
            userVotes.add(UserVote.fromSnapshot(doc.document));
          } else if (doc.type == DocumentChangeType.removed) {
            userVotes.add(UserVote.fromSnapshot(doc.document));
          }
        }
      });
    });
    setState(() {
      _initialized = true;
    });
  }*/
  Widget _itemBuilder(BuildContext context, int index) {
    String from = DateFormat.yMMMd("de_DE").format(userVotes[index].from);
    String to = DateFormat.yMMMd("de_DE").format(userVotes[index].to);
    String fromToLabel = "Zeitraum $from bis $to";
    int minHours = userVotes[index].minHours;
    int maxHours = userVotes[index].maxHours;
    String hoursLabel = "min. $minHours Stunden - max. $maxHours Stunden";

    return ListTile(
      title: Text(fromToLabel),
      subtitle: Text(hoursLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zeiträume'),
      ),
      body: LoaderBodyWidget(
        child: ListView.builder(
          itemBuilder: _itemBuilder,
          itemCount: userVotes.length,
        ),
        loading: !_initialized,
      ),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(
            Icons.add,
          ),
          label: Text('Bewerben'),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return LocationVoteEditor(
                employeeRoles: widget.employeeRoles,
              );
            }));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
