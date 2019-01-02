import 'dart:async';

import 'package:blaulichtplaner_app/shift_vote/shift_vote.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_day.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_model.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_month.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Shiftplan extends StatefulWidget {
  final ShiftplanModel plan;

  const Shiftplan({Key key, this.plan}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShiftplanState();
  }
}

class ShiftplanState extends State<Shiftplan> {
  bool _initialized = false;
  int _selectedTab = 0;
  DateTime _selectedDate;
  DateTime _startDate, _endDate;
  StreamSubscription _sub;
  ShiftHolder _shifts = new ShiftHolder();

  @override
  void initState() {
    super.initState();

    _startDate = _selectedDate = DateTime(
      widget.plan.from.year ?? DateTime.now().year,
      widget.plan.from.month ?? DateTime.now().month,
      widget.plan.from.day ?? DateTime.now().day,
      0,
      0,
    );
    _endDate = DateTime(
      widget.plan.to.year ?? DateTime.now().year,
      widget.plan.to.month ?? DateTime.now().month,
      widget.plan.to.day ?? DateTime.now().day,
      0,
      0,
    ).add(Duration(days: 1));

    _initDataListeners();
  }

  @override
  void didUpdateWidget(Shiftplan oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cancelDataListeners();
    _shifts.clear();
    _initDataListeners();
  }

  _initDataListeners() {
    print("Listening for shiftplans");
    Query query = Firestore.instance
        .collection('shifts')
        .where('shiftplanRef', isEqualTo: widget.plan.selfRef)
        .where('status', isEqualTo: 'public')
        .orderBy('from');
    _sub = query.snapshots().listen(
      (snapshot) {
        setState(() {
          for (final doc in snapshot.documentChanges) {
            if (doc.type == DocumentChangeType.added) {
              _shifts.add(Shift.fromSnapshot(doc.document));
            } else if (doc.type == DocumentChangeType.modified) {
              _shifts.modify(Shift.fromSnapshot(doc.document));
            } else if (doc.type == DocumentChangeType.removed) {
              _shifts.remove(Shift.fromSnapshot(doc.document));
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
    print(_selectedTab);
    switch (_selectedTab) {
      case 0:
        return ShiftplanDay(
          shifts: _shifts.getShiftsBetween(
            _selectedDate,
            _selectedDate.add(Duration(days: 1)),
          ),
        );
      case 1:
      default:
        return ShiftplanMonth(
          plan: widget.plan,
          shiftHolder: _shifts,
          selectDay: _selectDayCallback,
        );
    }
  }

  _selectDayCallback(DateTime selected) {
    setState(() {
      _selectedDate =
          DateTime(selected.year, selected.month, selected.day, 0, 0);
      _selectedTab = 0;
    });
  }

  String _weekOfYear() {
    DateTime startOfYear = new DateTime(_selectedDate.year, 1, 1, 0, 0);
    int firstWeek = 8 - startOfYear.weekday;
    Duration diff = _selectedDate.difference(startOfYear);
    int weeks =
        ((diff.inDays - firstWeek) / 7).ceil() + ((firstWeek > 3) ? 1 : 0);
    return 'KW $weeks';
  }

  Widget _createDateNavigation() {
    if (_selectedTab == 0) {
      List<Widget> navigation = <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(Duration(days: 1));
            });
          },
          color: Colors.white,
        ),
        FlatButton(
          child: Text(
            DateFormat.yMMMd("de_DE").format(_selectedDate),
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            showDatePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    initialDate: _selectedDate)
                .then((DateTime date) {
              setState(() {
                _selectedDate = date;
              });
            });
          },
        ),
        IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(Duration(days: 1));
              });
            },
            color: Colors.white)
      ];

      return PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: navigation,
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedTab,
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem<int>(
                  child: Text('Tag'),
                  value: 0,
                ),
                DropdownMenuItem<int>(
                  child: Text('Monat'),
                  value: 2,
                ),
              ],
              onChanged: (int val) {
                setState(() {
                  _selectedTab = val;
                });
              },
            ),
          ),
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
