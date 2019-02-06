import 'package:blaulichtplaner_app/assignment/assignment_view.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class AssignmentTabWidget extends StatefulWidget {
  final BottomNavigationBar bottomNavigationBar;
  final Widget drawer;
  final BlpUser user;

  const AssignmentTabWidget(
      {Key key,
      @required this.bottomNavigationBar,
      @required this.drawer,
      @required this.user})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AssignmentTabState();
  }
}

class _AssignmentTabState extends State<AssignmentTabWidget> {
  bool upcomingShifts = true;

  String _createTitle() {
    return upcomingShifts ? "Kommende Dienste" : "Vergangene Dienste";
  }

  List<Widget> _createAppBarActions() {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.rotate_90_degrees_ccw),
        onPressed: () {
          setState(() {
            upcomingShifts = !upcomingShifts;
          });
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_createTitle()),
        actions: _createAppBarActions(),
      ),
      drawer: widget.drawer,
      body: AssignmentView(
          employeeRoles: widget.user.employeeRoles(),
          upcomingShifts: upcomingShifts),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
