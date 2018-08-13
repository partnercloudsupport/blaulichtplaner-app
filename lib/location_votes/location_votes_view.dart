import 'package:flutter/material.dart';

class LocationVotesView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LocationVotesViewState();
  }
}

class LocationVotesViewState extends State<LocationVotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zeiträume'),
      ),
      body: null,
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(
            Icons.add,
          ),
          label: Text('Bewerben'),
          onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
