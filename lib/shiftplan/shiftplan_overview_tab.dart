import 'package:blaulichtplaner_app/shiftplan/shiftplan_overview.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class ShiftplanOverviewTabWidget extends StatelessWidget {
  final BottomNavigationBar bottomNavigationBar;
  final Widget drawer;
  final BlpUser user;

  const ShiftplanOverviewTabWidget(
      {Key key,
      @required this.bottomNavigationBar,
      @required this.drawer,
      @required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aktuelle Dienstpläne"),
      ),
      drawer: drawer,
      body: ShiftplanOverview(
        employeeRoles: user.employeeRoles(),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
