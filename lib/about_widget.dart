import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Über die App"),
      ),
      body: SingleChildScrollView(child: Center(child: Text('Hi'))),
    );
  }
}
