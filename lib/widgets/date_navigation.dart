import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef void OnChangedDate(DateTime date);

class DateNavigation extends StatefulWidget {
  final OnChangedDate onChanged;
  final DateTime initialValue;
  final DateTime fromDate;
  final DateTime toDate;

  const DateNavigation({
    Key key,
    @required this.onChanged,
    @required this.initialValue,
    @required this.fromDate,
    this.toDate,
  }) : super(key: key);
  @override
  DateNavigationState createState() {
    return new DateNavigationState();
  }
}

class DateNavigationState extends State<DateNavigation> {
  DateTime _selectedDate;
  DateTime _fromDate;
  DateTime _toDate;

  @override
  void initState() {
    _fromDate = widget.fromDate ?? DateTime.now();
    _selectedDate = widget.initialValue ?? DateTime.now();
    _toDate = widget.toDate ?? DateTime.now().add(Duration(days: 365));
    super.initState();
  }

  _subtractDay() {
    setState(() {
      _selectedDate =
          (_selectedDate.subtract(Duration(days: 1)).compareTo(_fromDate) >= 0)
              ? _fromDate
              : _selectedDate.subtract(Duration(days: 1));
    });
    widget.onChanged(_selectedDate);
  }

  _addDay() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 1));
    });
    widget.onChanged(_selectedDate);
  }

  _selectDay() {
    showDatePicker(
            context: context,
            firstDate: _fromDate.subtract(Duration(days: 1)),
            lastDate: _toDate,
            initialDate: _selectedDate)
        .then((DateTime date) {
      setState(() {
        _selectedDate = date;
      });
      widget.onChanged(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showMinusButton =
        (_selectedDate.subtract(Duration(days: 1)).compareTo(_fromDate) >= 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: showMinusButton ? _subtractDay : null,
          color: Colors.white,
        ),
        FlatButton(
          child: Text(
            DateFormat.yMMMd("de_DE").format(_selectedDate),
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _selectDay,
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: _addDay,
          color: Colors.white,
        )
      ],
    );
  }
}
