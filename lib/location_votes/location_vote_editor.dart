import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote_form.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote_service.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LocationVoteEditor extends StatefulWidget {
  final List<UserRole> employeeRoles;
  final UserVote userVote;

  const LocationVoteEditor(
      {Key key, @required this.employeeRoles, @required this.userVote})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationVoteEditorState(userVote);
  }
}

class LocationVoteEditorState extends State<LocationVoteEditor> {
  final UserVote userVote;

  LocationVoteEditorState(this.userVote);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dienstbewerbung")),
      body: SingleChildScrollView(
        child: LocationVoteForm(
          userVote: userVote,
          saveLocationVote: (BuildContext context, UserVote userVote) async {
            BlpUser user = UserWidget.of(context).user;

            UserVoteService service = UserVoteService();
            try {
              await service.save(userVote, user);
              Navigator.pop(context);
            } catch (e) {
              print(e);
            }
          },
          employeeRoles: widget.employeeRoles,
        ),
      ),
    );
  }
}
