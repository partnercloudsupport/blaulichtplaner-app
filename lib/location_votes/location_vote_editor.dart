import 'package:blaulichtplaner_app/location_votes/location_vote_form.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LocationVoteEditor extends StatefulWidget {
  final List<Role> employeeRoles;

  const LocationVoteEditor({Key key, @required this.employeeRoles})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationVoteEditorState();
  }
}

class LocationVoteEditorState extends State<LocationVoteEditor> {
  final LocationVote locationVote = LocationVote();

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
          locationVote: locationVote,
          saveLocationVote: (BuildContext context, LocationVote locationVote) {
            print(locationVote);
            Navigator.pop(context);
          },
          employeeRoles: widget.employeeRoles,
        ),
      ),
    );
  }
}
