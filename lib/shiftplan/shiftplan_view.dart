import 'package:flutter/material.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';

class ShiftplanView extends StatefulWidget {
  final List<Role> employeeRoles;
  ShiftplanView({
    Key key,
    this.employeeRoles,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShiftplanViewState();
  }
}

class ShiftplanViewState extends State<ShiftplanView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Dienstpläne'),
    );
  }
}
