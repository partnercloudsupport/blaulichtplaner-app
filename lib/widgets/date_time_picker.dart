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

  final dateFormatter = DateFormat('EE, dd.MM.yyyy', 'de_DE');
  final timeFormatter = DateFormat.Hm('de_DE');
  final inputTextStyle = TextStyle(fontSize: 18.0);
  final overtimeInputTextStyle = TextStyle(fontSize: 18.0, color: Colors.red);

  DateTimePickerWidget(
      {Key key,
      @required this.dateTime,
       this.dateTimeChanged,
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
        flex: 5,
        child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Text(
                    DateFormat('EE, ', 'de_DE').format(dateTime),
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Text(
                    DateFormat('dd.MM.yyyy', 'de_DE').format(dateTime),
                    style: TextStyle(fontSize: 18.0),
                  ),
                )
              ],
            ),
          ),
          onTap: dateTimeChanged != null ? _createFromDateTapHandler(context) : null,
        ),
      ),
      Expanded(
        flex: 2,
        child: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              timeFormatter.format(dateTime),
              style: inputTextStyle,
            ),
          ),
          onTap: dateTimeChanged != null ? _createFromTimeTapHandler(context) : null,
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
        int overtimeMinutes = (minutesDuration.inMinutes < 0)
            ? -minutesDuration.inMinutes
            : minutesDuration.inMinutes;

        overtimeDurationLabel = ((overtimeDuration.inMilliseconds > 0)
                ? "(+"
                : "(") +
            overtimeHours.toString() +
            "h" +
            (overtimeMinutes > 0 ? (overtimeMinutes.toString() + "m") : "") +
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

class DatePickerWidget extends StatelessWidget {
  final DateTime dateTime;
  final DateTime originalDateTime;
  final bool fixedDates;
  final DateTimeChanged dateTimeChanged;
  final String label;

  DatePickerWidget({
    Key key,
    @required this.dateTime,
    @required this.dateTimeChanged,
    this.fixedDates = true,
    this.originalDateTime,
    this.label = "",
  }) : super(key: key);

  GestureTapCallback _createFromDateTapHandler(BuildContext context) {
    return () async {
      if (fixedDates) {
        Scaffold.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 3),
            content: Text("Bei vorgegebenen Schichten können "
                "die Start- und Enddaten nicht geändert werden.")));
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

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List();

    if (label.length > 0) {
      children.add(Text(label));
    }
    children.add(
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  DateFormat('EE, ', 'de_DE').format(dateTime),
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              Text(
                DateFormat('dd.MM.yyyy', 'de_DE').format(dateTime),
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
        onTap: _createFromDateTapHandler(context),
      ),
    );

    return Column(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
