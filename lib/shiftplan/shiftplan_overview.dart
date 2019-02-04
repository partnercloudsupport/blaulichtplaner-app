import 'package:blaulichtplaner_app/shiftplan/shiftplan_view.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_model.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:flutter/material.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';
import 'dart:async';

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
  ShiftplanHolder _shiftplans = new ShiftplanHolder();
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
            .where('status', isEqualTo: 'public')
            .orderBy('to');
        _subs.add(query.snapshots().listen((snapshot) {
          setState(() {
            for (final doc in snapshot.documentChanges) {
              print(role.label);
              if (doc.type == DocumentChangeType.added) {
                _shiftplans.add(ShiftplanModel.fromSnapshot(
                    doc.document, role.label));
              } else if (doc.type == DocumentChangeType.modified) {
                _shiftplans.modify(ShiftplanModel.fromSnapshot(
                    doc.document, role.label));
              } else if (doc.type == DocumentChangeType.removed) {
                _shiftplans.remove(ShiftplanModel.fromSnapshot(
                    doc.document, role.label));
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
            return Card(
              child: ListTile(
                title: Text(
                    _shiftplans.plans[index].label ?? 'Dienstplan ohne Name'),
                subtitle: Text(_shiftplans.plans[index].companyLabel ??
                    'Unbekannte Firma'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          Shiftplan(plan: _shiftplans.plans[index]),
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
        fallbackText: 'Sie haben keine Dienstpläne',
      );
    } else {
      return NoEmployee();
    }
  }
}
