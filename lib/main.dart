import 'package:blaulichtplaner_app/launch_screen_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // debugPaintSizeEnabled = true;
  Firestore firestore = Firestore.instance;
  firestore.settings(timestampsInSnapshotsEnabled: true);
  initializeDateFormatting();
  runApp(ShiftplanApp());
}

class ShiftplanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blaulichtplaner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LaunchScreen(),
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: true,
    );
  }
}
