import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftVoteMessage extends StatelessWidget {
  final Shift shift;
  final simpleDateFormatter = DateFormat.yMd("de_DE");

  ShiftVoteMessage({Key key, @required this.shift}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shift.hasShiftPassed()) {
      return Container();
    } else {
      String message;
      if (shift.voteFrom != null && shift.voteTo != null) {
        message =
            "Bewerbungsphase läuft vom ${simpleDateFormatter.format(shift.voteFrom)} bis ${simpleDateFormatter.format(shift.voteTo)}";
      } else {
        message = "Bewerbungen im Moment nicht möglich.";
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(message,
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      );
    }
  }
}
