import 'package:blaulichtplaner_app/shift_vote/shift_vote.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftBadge extends StatelessWidget {
  final Shift shift;
  final Function onTap;

  const ShiftBadge({Key key, this.onTap, this.shift}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String from = shift.from.minute == 0
        ? DateFormat('H').format(shift.from)
        : DateFormat('H:mm').format(shift.from);
    String to = DateFormat('H:mm').format(shift.to);
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Text(
              shift.locationLabel,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
            Text(
              shift.workAreaLabel,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black.withAlpha(0x8f),
              ),
            ),
            Text(
              '$from-$to',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black.withAlpha(0x8f),
              ),
            )
          ],
        ),
        decoration: BoxDecoration(
          color: shift.manned ? Colors.greenAccent : Colors.redAccent,
          borderRadius: BorderRadius.circular(3.0),
          border: Border.all(
            color: Colors.black.withAlpha(0x1f),
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
        padding: EdgeInsets.all(2.0),
        width: double.infinity,
      ),
    );
  }
}

class ShiftplanMonth extends StatelessWidget {
  final _keys = const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  final Function selectDay;
  final ShiftHolder shiftHolder;
  final ShiftplanModel plan;

  const ShiftplanMonth(
      {Key key,
      this.selectDay,
      @required this.shiftHolder,
      @required this.plan})
      : super(key: key);

  Widget _caption() {
    List<Widget> elements = <Widget>[];
    for (String key in _keys) {
      elements.add(
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.25),
            ),
            alignment: Alignment.center,
            height: 50.0,
            child: Text(key),
          ),
        ),
      );
    }
    return Row(
      children: elements,
    );
  }

  Widget _week(DateTime from) {
    List<Widget> row = [];

    for (int i = 0; i < 7; i++) {
      DateTime day = from.add(Duration(days: i));
      List<Widget> shiftBadges = <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 1.0),
          child: Text(
            '${day.day}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
          ),
        ),
      ];
      List<Shift> shifts =
          shiftHolder.getShiftsBetween(day, day.add(Duration(days: 1)));
      if (shifts.length > 2) {
        shifts = shifts.sublist(0, 2);
        shifts.forEach((Shift shift) {
          shiftBadges.add(ShiftBadge(
            shift: shift,
            onTap: () {
              selectDay(day);
            },
          ));
        });
        shiftBadges.add(Container(
          width: double.infinity,
          child: Text(
            '...',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black.withAlpha(0x8f)),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(
              color: Colors.black.withAlpha(0x1f),
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
        ));
      } else {
        shifts.forEach((Shift shift) {
          shiftBadges.add(ShiftBadge(
            shift: shift,
            onTap: () {
              selectDay(day);
            },
          ));
        });
      }

      row.add(
        Expanded(
          flex: 1,
          child: Container(
            height: 150.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.25),
            ),
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: shiftBadges,
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: row);
  }

  Future<Widget> _month() async {
    List<Widget> rows = [];
    DateTime from = plan.from.subtract(Duration(days: plan.from.weekday - 1));
    DateTime to = plan.to.add(Duration(days: 7 - plan.to.weekday));

    for (int i = 0; i < (to.difference(from).inDays / 7); i++) {
      rows.add(_week(from.add(Duration(days: i * 7))));
    }

    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _caption(),
          FutureBuilder(
            future: _month(),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.only(top: 50, bottom: 10),
                  child: CircularProgressIndicator(),
                );
              }
              return snapshot.data;
            },
          )
        ],
      ),
    );
  }
}
