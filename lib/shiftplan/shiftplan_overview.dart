import 'package:blaulichtplaner_app/shiftplan/shiftplan_view.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_model.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';
import 'dart:async';

class ShiftplanOverview extends StatefulWidget {
  final List<Role> employeeRoles;
  ShiftplanOverview({
    Key key,
    @required this.employeeRoles,
  }) : super(key: key);

  bool hasEmployeeRoles() {
    return employeeRoles != null && employeeRoles.isNotEmpty;
  }

  @override
  State<StatefulWidget> createState() {
    return ShiftplanOverviewState();
  }
}

class ShiftplanOverviewState extends State<ShiftplanOverview> {
  bool _initialized = false;
  final List<StreamSubscription> _subs = [];
  ShiftplanHolder _shiftplans = new ShiftplanHolder();
  @override
  void initState() {
    super.initState();
    _initDataListeners();
  }

  _initDataListeners() {
    if (widget.hasEmployeeRoles()) {
      print("Listening for shiftplans");
      for (Role role in widget.employeeRoles) {
        Query query = role.locationRef
            .collection('shiftplans')
            .where('status', isEqualTo: 'public')
            .orderBy('to');
        _subs.add(query.snapshots().listen((snapshot) {
          setState(() {
            for (final doc in snapshot.documentChanges) {
              print(role.companyLabel);
              if (doc.type == DocumentChangeType.added) {
                _shiftplans.add(ShiftplanModel.fromSnapshot(
                    doc.document, role.companyLabel));
              } else if (doc.type == DocumentChangeType.modified) {
                _shiftplans.modify(ShiftplanModel.fromSnapshot(
                    doc.document, role.companyLabel));
              } else if (doc.type == DocumentChangeType.removed) {
                _shiftplans.remove(ShiftplanModel.fromSnapshot(
                    doc.document, role.companyLabel));
              }
            }
            _initialized = true;
          });
        }));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cancelDataListeners();
  }

  void _cancelDataListeners() {
    for (final sub in _subs) {
      sub.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.hasEmployeeRoles()){
    return LoaderBodyWidget(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_shiftplans.plans[index].label ?? 'Kein bla'),
            subtitle: Text(_shiftplans.plans[index].companyLabel ?? 'Kein bla'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      Shiftplan(plan: _shiftplans.plans[index]),
                ),
              );
            },
          );
        },
        itemCount: _shiftplans.plans.length,
      ),
      empty: _shiftplans.isEmpty,
      loading: !_initialized,
      fallbackText: 'Sie haben keine Dienstpläne',
    );
    } else{
      return NoEmployee();
    }
  }
}
