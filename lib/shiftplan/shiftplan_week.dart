import 'package:blaulichtplaner_app/shift_vote/shift_vote.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftplanWeek extends StatelessWidget {
  final DateTime selected;
  final List<Shift> shifts;

  const ShiftplanWeek({
    Key key,
    @required this.selected,
    @required this.shifts,
  }) : super(key: key);

  Widget _shifts(DateTime day) {
    DateFormat timeFormatter = DateFormat('EE dd.MM.', 'de_DE');
    DateFormat smallTime = DateFormat.Hm('de_DE');
    List<Shift> elements = shifts
        .where(
          (Shift shift) =>
              shift.from.isAfter(day) &&
              shift.to.isBefore(day.add(Duration(days: 1))),
        )
        .toList();
    List<Widget> widgets = <Widget>[];
    for (Shift element in elements) {
      widgets.add(
        Container(
          padding: EdgeInsets.all(4.0),
          child: Column(children: <Widget>[
            Text(
              '${smallTime.format(element.from)} - ${smallTime.format(element.to)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Chip(
              label: Text(element.workAreaLabel),
              padding: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.black.withAlpha(0x1f),
                      width: 1.0,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(28.0)),
            ),
            Chip(
              label: Text(element.locationLabel),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.black.withAlpha(0x1f),
                      width: 1.0,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(28.0)),
              padding: EdgeInsets.all(0.0),
            ),
          ], mainAxisAlignment: MainAxisAlignment.start,),
          width: 124.0,
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.all(
              Radius.circular(6.0),
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        Container(
          child: Text(
            timeFormatter.format(day),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.25),
          ),
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.topLeft,
          width: 140.0,
          height: 50.0,
        ),
        Expanded(
          child: Container(
            child: Column(
              children: widgets,
            ),
            width: 140.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.25),
            ),
            padding: EdgeInsets.all(8.0),
          ),
        ),
      ],
    );
  }

  List<Widget> _caption() {
    List<Widget> widgets = <Widget>[];
    for (int i = 0; i < 7; i++) {
      DateTime day = selected.add(Duration(days: i));
      widgets.add(_shifts(day));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _caption(),
      ),
    );
  }
}
