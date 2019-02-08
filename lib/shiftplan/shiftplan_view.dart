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
  bool _selectMonth = true;
  DateTime _selectedDate = DateTime.now();
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
        .where('status', isEqualTo: 'public')
        .orderBy('from');
    _sub = query.snapshots().listen(
      (snapshot) {
        setState(() {
          for (final doc in snapshot.documentChanges) {
            Shift shift = Shift.fromSnapshot(doc.document, widget.plan.employeeRef);
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
    if (_selectMonth) {
      return ShiftplanMonth(
        plan: widget.plan,
        shiftHolder: _shifts,
        selectDay: _selectDayCallback,
      );
    } else {
      return ShiftplanDay(
        shifts: _shifts.getShiftsBetween(
          _selectedDate,
          _selectedDate.add(Duration(days: 1)),
        ),
      );
    }
  }

  _selectDayCallback(DateTime selected) {
    setState(() {
      _selectedDate =
          DateTime(selected.year, selected.month, selected.day, 0, 0);
      _selectMonth = false;
    });
  }

  Widget _createDateNavigation() {
    if (_selectMonth) {
      return null;
    } else {
      return PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: DateNavigation(
          initialValue: _selectedDate,
          fromDate: widget.plan.from,
          toDate: widget.plan.to,
          onChanged: _selectDayCallback,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(_selectMonth ? Icons.view_day : Icons.view_week),
            onPressed: () {
              setState(() {
                _selectMonth = !_selectMonth;
              });
            },
          )
        ],
        bottom: _createDateNavigation(),
        title: Text(widget.plan.label ?? 'Dienstplan'),
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
