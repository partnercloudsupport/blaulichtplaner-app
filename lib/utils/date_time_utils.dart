import 'package:flutter/material.dart';

dateTimeWithDateFrom(DateTime dateTime, DateTime otherDate) {
  return new DateTime(otherDate.year, otherDate.month, otherDate.day,
      dateTime.hour, dateTime.minute, dateTime.second);
}

dateTimeWithTimeFrom(DateTime dateTime, TimeOfDay time) {
  return new DateTime(
      dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);
}
