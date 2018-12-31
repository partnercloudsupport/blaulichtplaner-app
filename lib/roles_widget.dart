import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';

class RolesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RolesScreenState();
  }
}

class RolesScreenState extends State<RolesScreen> {
  FirebaseUser user;
  @override
  void initState() {
    super.initState();
    user = UserManager.get().user;
  }

  Widget _tileBuilder(BuildContext context, Role role) {
    String sinceLabel = 'Seit ' + DateFormat.yMMM("de_DE").format(role.created);
    return ListTile(
      title: Text(role.companyLabel),
      trailing: Text(sinceLabel),
    );
  }

  Widget _streamBuilder(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if(!snapshot.hasData){
      return Center(child: CircularProgressIndicator(),);
    }
    if(snapshot.data.documents.isEmpty){
      return NoEmployee();
    }
    return ListView.builder(
      itemCount: snapshot.data.documents.length,
      itemBuilder: (BuildContext context, int index) {
        return _tileBuilder(
            context, Role.fromSnapshot(snapshot.data.documents[index].data));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zugeordnete Firmen"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        builder: _streamBuilder,
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .collection("roles")
            .snapshots(),
      ),
    );
  }
}
