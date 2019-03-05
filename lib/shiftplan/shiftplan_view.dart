import 'dart:async';

import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_day.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_model.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_month.dart';
import 'package:blaulichtplaner_app/widgets/date_navigation.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class ShiftplanWidget extends StatefulWidget {
  final ShiftplanModel plan;

  const ShiftplanWidget({Key key, this.plan}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShiftplanWidgetState();
  }
}

class ShiftplanWidgetState extends State<ShiftplanWidget> {
  bool _initialized = false;
  StreamSubscription _sub;
  ShiftHolder _shifts = new ShiftHolder();

  @override
  void initState() {
    super.initState();
    _initDataListeners();
  }

  @override
  void didUpdateWidget(ShiftplanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cancelDataListeners();
    _shifts.clear();
    _initDataListeners();
  }

  _initDataListeners() {
    print("Listening for shiftplans");
    Query query = FirestoreImpl.instance
        .collection('shifts')
        .where('shiftplanRef', isEqualTo: widget.plan.selfRef)
        .orderBy('from');
    _sub = query.snapshots().listen(
      (snapshot) {
        setState(() {
          for (final doc in snapshot.documentChanges) {
            EmployeeShift shift = EmployeeShift.fromSnapshot(
                doc.document, widget.plan.employeeRef);
            if (doc.type == DocumentChangeType.added) {
              _shifts.add(shift);
            } else if (doc.type == DocumentChangeType.modified) {
              _shifts.modify(shift);
            } else if (doc.type == DocumentChangeType.removed) {
              _shifts.remove(shift);
            }
          }
          _initialized = true;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _cancelDataListeners();
  }

  void _cancelDataListeners() {
    _sub.cancel();
  }

  Widget _buildBody() {
    return ShiftplanMonth(
      plan: widget.plan,
      shiftHolder: _shifts,
      selectDay: _selectDayCallback,
    );
  }

  _selectDayCallback(DateTime selected) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.shiftplanLabel),
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.plan.title,
              style: TextStyle(color: Colors.white),
            ),
          ),
          preferredSize: Size.fromHeight(16),
        ),
      ),
      body: LoaderBodyWidget(
        child: _buildBody(),
        loading: !_initialized,
        empty: false,
        fallbackText: 'Keine Schichten in diesem Dienstplan',
      ),
    );
  }
}
