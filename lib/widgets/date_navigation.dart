import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef void OnChangedDate(DateTime date);

class DateNavigation extends StatefulWidget {
  final OnChangedDate onChanged;
  final DateTime initialValue;

  const DateNavigation({Key key, @required this.onChanged, this.initialValue})
      : super(key: key);
  @override
  DateNavigationState createState() {
    return new DateNavigationState();
  }
}

class DateNavigationState extends State<DateNavigation> {
  DateTime _selectedDate;
  DateTime _initialDate;

  @override
  void initState() {
    _initialDate = widget.initialValue ?? DateTime.now();
    _selectedDate = _initialDate;
    super.initState();
  }

  _subtractDay() {
    setState(() {
      _selectedDate =
          (_selectedDate.subtract(Duration(days: 1)).compareTo(_initialDate) >=
                  0)
              ? _initialDate
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
            firstDate: _initialDate.subtract(Duration(days: 1)),
            lastDate: DateTime.now().add(Duration(days: 365)),
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
        (_selectedDate.subtract(Duration(days: 1)).compareTo(_initialDate) >=
            0);
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
