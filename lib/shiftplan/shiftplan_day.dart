import 'package:blaulichtplaner_app/shift_vote/shift_vote.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftplanDay extends StatelessWidget {
  final List<Shift> shifts;

  const ShiftplanDay({Key key, @required this.shifts}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    DateFormat timeFormatter = DateFormat('EE HH:mm', 'de_DE');
    if (shifts.isEmpty) {
      return Center(
        child: Text('Keine Inhalte', style: TextStyle(color: Colors.black)),
      );
    } else {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          String timeLabel =
              'Schicht ${timeFormatter.format(shifts[index].from)} bis ${timeFormatter.format(shifts[index].to)}';
          return Card(
            color: Colors.greenAccent,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  title: Text(
                    timeLabel,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: <Widget>[
                      Chip(
                        label: Text(shifts[index].workAreaLabel),
                        padding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black.withAlpha(0x1f),
                                width: 1.0,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(28.0)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Chip(
                          label: Text(shifts[index].locationLabel),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.black.withAlpha(0x1f),
                                  width: 1.0,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(28.0)),
                          padding: EdgeInsets.all(0.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    bottom: 8.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Chip(
                        label: Row(
                          children: <Widget>[
                            Text(
                              '${shifts[index].manned ? shifts[index].requiredEmployees : '0'} / ${shifts[index].requiredEmployees}',
                              style: TextStyle(
                                color: shifts[index].manned
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.person,
                              size: 15.0,
                              color: shifts[index].manned
                                    ? Colors.green
                                    : Colors.red,
                            )
                          ],
                        ),
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: shifts[index].manned
                                    ? Colors.green
                                    : Colors.red,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(28.0)),
                        padding: EdgeInsets.all(0.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: shifts.length,
      );
    }
  }
}
