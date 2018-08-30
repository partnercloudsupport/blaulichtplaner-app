import 'dart:async';

import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:intl/intl.dart';

class RolesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RolesScreenState();
  }
}

class RolesScreenState extends State<RolesScreen> {
  bool _initialized = false;
  List<Map<String, dynamic>> _roles = [];
  FirebaseUser user;
  @override
  void initState() {
    super.initState();
    user = UserManager.get().user;
    if (user != null) {
      _fetchRoles(user).then((dynamic nul) {
        setState(() {
          _initialized = true;
        });
      });
    } else {
      print('Nothing');
    }
  }

  Future<void> _fetchRoles(FirebaseUser user) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection("roles")
        .getDocuments();
    for (DocumentSnapshot doc in snapshot.documents) {
      Role role = Role.fromSnapshot(doc.data);

      if (role.type == "employee") {
        Map<String, dynamic> contents = {
          "companyLabel": role.companyLabel ?? "Keine Firma",
          "locationLabel": role.locationLabel ?? "Kein Standort",
          "created": role.created ?? DateTime.now(),
        };
        _roles.add(contents);
      }
    }
  }

  Widget _tileBuilder(BuildContext context, int index) {
    return ListTile(
      title: Text(_roles[index]["locationLabel"]),
      subtitle: Text(_roles[index]["companyLabel"]),
      trailing: Text(
          "Seit " + DateFormat.yMMM("de_DE").format(_roles[index]["created"])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zugeordnete Standorte"),
      ),
      body: LoaderBodyWidget(
        loading: !_initialized,
        child: ListView.builder(
          itemCount: _roles.length,
          itemBuilder: _tileBuilder,
        ),
        fallbackText: 'Keine Einträge',
        empty: _roles.isEmpty,
      ),
    );
  }
}
