import 'package:blaulichtplaner_app/shift/shift_view.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_model.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftBadge extends StatelessWidget {
  final Shift shift;
  final Function onTap;

  const ShiftBadge({Key key, this.onTap, this.shift}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    DateTime fromDateTime = shift.from;
    DateTime toDateTime = shift.to;
    String from = fromDateTime.minute == 0
        ? DateFormat('H').format(fromDateTime)
        : DateFormat('H:mm').format(fromDateTime);
    String to = DateFormat('H:mm').format(toDateTime);
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

class ShiftplanMonth extends StatefulWidget {
  final Function selectDay;
  final ShiftHolder shiftHolder;
  final ShiftplanModel plan;

  const ShiftplanMonth(
      {Key key,
      this.selectDay,
      @required this.shiftHolder,
      @required this.plan})
      : super(key: key);

  @override
  ShiftplanMonthState createState() {
    return ShiftplanMonthState();
  }
}

class ShiftplanMonthState extends State<ShiftplanMonth> {
  final _keys = const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

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
      List<EmployeeShift> shifts =
          widget.shiftHolder.getShiftsBetween(day, day.add(Duration(days: 1)));
      shifts.forEach((EmployeeShift shift) {
        shiftBadges.add(InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return ShiftViewWidget(
                shiftRef: shift.shiftRef,
                currentEmployeeRef: shift.employeeRef,
              );
            }));
          },
          child: ShiftBadge(
            shift: shift,
          ),
        ));
      });

      row.add(
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.25),
            ),
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                
                children: shiftBadges,
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: row, crossAxisAlignment: CrossAxisAlignment.start,);
  }

  Widget _month() {
    List<Widget> rows = [];
    DateTime from = widget.plan.startOfPlan();
    DateTime to = widget.plan.endOfPlan();

    for (int i = 0; i < (to.difference(from).inDays / 7); i++) {
      rows.add(_week(from.add(Duration(days: i * 7))));
    }

    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [_caption(), _month()],
      ),
    );
  }
}
