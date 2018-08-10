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
  List<Role> _roles = [];
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
      List<String> parts = role.reference.path.split('/');
      CollectionReference ref = Firestore.instance.collection('companies');
      DocumentSnapshot company = await ref.document(parts[1]).get();
      role.label = company.data["companyName"];
      DocumentSnapshot location = await ref.document(parts[1]).collection('locations').document(parts[3]).get();
      role.role = location.data["locationName"];
      _roles.add(role);
      }
    }
  }

  Widget _tileBuilder(BuildContext context, int index) {
    return ListTile(
      title: Text(_roles[index].label ?? "${_roles[index].reference.path}"),
      subtitle: Text(_roles[index].role),
      trailing: Text("Seit ${DateFormat.yMMM("de_DE").format(_roles[index].created)}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: <Widget>[
                Padding(
                  child: Icon(Icons.location_on),
                  padding: EdgeInsets.only(right: 8.0),
                ),
                Text("Zugeordnete Standorte")
              ])),
      body: LoaderBodyWidget(
        loading: !_initialized,
        child: _roles.isEmpty
            ? Text('Keine Einträge')
            : ListView.builder(
                itemCount: _roles.length,
                itemBuilder: _tileBuilder,
              ),
      ),
    );
  }
}
