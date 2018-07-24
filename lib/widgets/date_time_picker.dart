import 'package:blaulichtplaner_app/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

typedef void DateTimeChanged(DateTime dateTime);

class DateTimePickerWidget extends StatelessWidget {
  final DateTime dateTime;
  final bool fixedDates;
  final DateTimeChanged dateTimeChanged;

  final dateFormatter = DateFormat.EEEE("de_DE").add_yMd();
  final timeFormatter = DateFormat.Hm("de_DE");
  final inputTextStyle = TextStyle(fontSize: 18.0);

  DateTimePickerWidget(
      {Key key,
      @required this.dateTime,
      @required this.dateTimeChanged,
      this.fixedDates = true})
      : super(key: key);

  void _showFixedDatesSnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar( duration: Duration(seconds: 3),
        content: Text("Bei vorgegebenen Schichten können "
            "die Start- und Endzeiten nicht geändert werden.")));
  }

  GestureTapCallback _createFromDateTapHandler(BuildContext context) {
    return () {
      if (fixedDates) {
        _showFixedDatesSnackBar(context);
        return null;
      } else {
        showDatePicker(
            context: context,
            initialDate: dateTime,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 356))).then((newValue) {
          if (newValue != null) {
            dateTimeChanged(dateTimeWithDateFrom(dateTime, newValue));
          }
        });
      }
    };
  }

  GestureTapCallback _createFromTimeTapHandler(BuildContext context) {
    return () {
      if (fixedDates) {
        _showFixedDatesSnackBar(context);
        return null;
      } else {
        showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(dateTime)).then((newValue) {
          if (newValue != null) {
            dateTimeChanged(dateTimeWithTimeFrom(dateTime, newValue));
          }
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
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
      ],
    );
  }
}
