import 'package:blaulichtplaner_app/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

typedef void DateTimeChanged(DateTime dateTime);

class DateTimePickerWidget extends StatelessWidget {
  final DateTime dateTime;
  final DateTime originalDateTime;
  final bool fixedDates;
  final DateTimeChanged dateTimeChanged;

  final dateFormatter = DateFormat.EEEE("de_DE").add_yMd();
  final timeFormatter = DateFormat.Hm("de_DE");
  final inputTextStyle = TextStyle(fontSize: 18.0);
  final overtimeInputTextStyle = TextStyle(fontSize: 18.0, color: Colors.red);

  DateTimePickerWidget(
      {Key key,
      @required this.dateTime,
      @required this.dateTimeChanged,
      this.fixedDates = true,
      this.originalDateTime})
      : super(key: key);

  void _showFixedDatesSnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text("Bei vorgegebenen Schichten können "
            "die Start- und Endzeiten nicht geändert werden.")));
  }

  GestureTapCallback _createFromDateTapHandler(BuildContext context) {
    return () async {
      if (fixedDates) {
        _showFixedDatesSnackBar(context);
      } else {
        final newValue = await showDatePicker(
            context: context,
            initialDate: dateTime,
            firstDate: dateTime.subtract(Duration(days: 356)),
            lastDate: dateTime.add(Duration(days: 356)));
        if (newValue != null) {
          dateTimeChanged(dateTimeWithDateFrom(dateTime, newValue));
        }
      }
    };
  }

  GestureTapCallback _createFromTimeTapHandler(BuildContext context) {
    return () async {
      if (fixedDates) {
        _showFixedDatesSnackBar(context);
      } else {
        final newValue = await showTimePicker(
            context: context, initialTime: TimeOfDay.fromDateTime(dateTime));
        if (newValue != null) {
          dateTimeChanged(dateTimeWithTimeFrom(dateTime, newValue));
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rowChildren = [
      Expanded(
        flex: 2,
        child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text(
              dateFormatter.format(dateTime),
              style: inputTextStyle,
            ),
          ),
          onTap: _createFromDateTapHandler(context),
        ),
      ),
      Expanded(
        flex: 1,
        child: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              timeFormatter.format(dateTime),
              style: inputTextStyle,
            ),
          ),
          onTap: _createFromTimeTapHandler(context),
        ),
      ),
    ];
    String overtimeDurationLabel = "";
    if (originalDateTime != null) {
      final overtimeDuration = dateTime.difference(originalDateTime);
      if (overtimeDuration.inMilliseconds != 0) {
        int overtimeHours = overtimeDuration.inHours;
        final minutesDuration =
            overtimeDuration - Duration(hours: overtimeHours);
        int overtimeMinutes = (minutesDuration.inMinutes <0) ? -minutesDuration.inMinutes : minutesDuration.inMinutes;

        overtimeDurationLabel =
            ((overtimeDuration.inMilliseconds > 0) ? "(+" : "(") +
                overtimeHours.toString() +
                "h" +
                (overtimeMinutes > 0
                    ? (overtimeMinutes.toString() + "m")
                    : "") +
                ")";
      }
    }

    rowChildren.add(Expanded(
      flex: 1,
      child: Text(
        overtimeDurationLabel,
        style: overtimeInputTextStyle,
      ),
    ));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rowChildren,
    );
  }
}
