import 'package:blaulichtplaner_app/launch_screen_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  // debugPaintSizeEnabled = true;
  Firestore firestore = Firestore.instance;
  FirebaseOptions options = await firestore.app.options;
  print("Using database: ${options.databaseURL}");
  firestore.settings(timestampsInSnapshotsEnabled: true);
  //initializeDateFormatting(); // don't call this if using localization
  runApp(ShiftplanApp());
}

class ShiftplanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', 'US'), Locale("de", "DE")],
      title: 'Blaulichtplaner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LaunchScreen(),
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
    );
  }
}
