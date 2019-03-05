import 'package:blaulichtplaner_app/shiftplan/shiftplan_view.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_model.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:flutter/material.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class ShiftplanOverview extends StatefulWidget {
  final List<UserRole> employeeRoles;
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
  ShiftplanHolder _shiftplans = ShiftplanHolder();
  final simpleDateFormatter = DateFormat.yMd("de_DE");

  @override
  void initState() {
    super.initState();
    _initDataListeners();
  }

  _initDataListeners() {
    if (widget.hasEmployeeRoles()) {
      print("Listening for shiftplans");
      for (UserRole role in widget.employeeRoles) {
        Query query = role.reference
            .collection('shiftplans')
            .where("to", isGreaterThan: DateTime.now())
            .orderBy('to', descending: true)
            .orderBy("locationLabel");
        _subs.add(query.snapshots().listen((snapshot) {
          setState(() {
            for (final doc in snapshot.documentChanges) {
              print(role.label);
              ShiftplanModel shiftplanModel = ShiftplanModel.fromSnapshot(
                  doc.document, role.label, role.employeeRef);
              if (doc.type == DocumentChangeType.added) {
                _shiftplans.add(shiftplanModel);
              } else if (doc.type == DocumentChangeType.modified) {
                _shiftplans.modify(shiftplanModel);
              } else if (doc.type == DocumentChangeType.removed) {
                _shiftplans.remove(shiftplanModel);
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
    if (widget.hasEmployeeRoles()) {
      return LoaderBodyWidget(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            ShiftplanModel plan = _shiftplans.plans[index];
            String subtitle =
                "${simpleDateFormatter.format(plan.from)} - ${simpleDateFormatter.format(plan.to)}";
            return Card(
              child: ListTile(
                title: Text(plan.shiftplanLabel + " (" + plan.title + ")"),
                subtitle: Text(subtitle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ShiftplanWidget(plan: plan),
                    ),
                  );
                },
              ),
            );
          },
          itemCount: _shiftplans.plans.length,
        ),
        empty: _shiftplans.isEmpty,
        loading: !_initialized,
        fallbackText: 'Es sind keine Dienstpläne erstellt',
      );
    } else {
      return NoEmployee();
    }
  }
}
