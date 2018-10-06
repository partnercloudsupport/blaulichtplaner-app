import 'package:flutter/material.dart';

class WeekRow extends StatelessWidget {
  final int i;
  WeekRow(this.i);
  _miniChip(String title, String subtitle, Function onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black.withAlpha(0x8f),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(
              color: Colors.black.withAlpha(0x1f),
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
          padding: EdgeInsets.all(2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> row = <Widget>[];
    for (int j = 0; j < 7; j++) {
      if ((i * 7 + j + 1) < 32) {
        List<Widget> shifts = <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${i * 7 + j + 1}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
          ),
          _miniChip('Notdienst', 'Gesundbrunnen', () {}),
          ((j % 3) == 0)
              ? _miniChip('Notdienst', 'Gesundbrunnen', () {})
              : Text(''),
        ];
        row.add(
          Expanded(
            flex: 1,
            child: Container(
              height: 150.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.25),
              ),
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: shifts,
                ),
              ),
            ),
          ),
        );
      } else {
        row.add(
          Expanded(
            flex: 1,
            child: Container(),
          ),
        );
      }
    }
    return Row(
      children: row,
    );
  }
}

class ShiftplanMonth extends StatelessWidget {
  final _keys = const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  final Function selectDay;

  const ShiftplanMonth({Key key, this.selectDay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    List<Widget> _month() {
      List<Widget> elements = <Widget>[_caption()];
      for (int i = 0; i < 5; i++) {
        elements.add(WeekRow(i));
      }
      return elements;
    }

    return SingleChildScrollView(
      child: Column(
        children: _month(),
      ),
    );
  }
}
