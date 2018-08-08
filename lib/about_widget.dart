import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children:<Widget>[Padding(child: Icon(Icons.info_outline), padding: EdgeInsets.only(right: 8.0),),Text("Über die App")]),
      ),
      body: Column(children: <Widget>[]),
    );
  }
}
