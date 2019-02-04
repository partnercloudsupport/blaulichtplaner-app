import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
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

  Widget _tileBuilder(BuildContext context, UserRole role) {
    String sinceLabel = 'Seit ' + DateFormat.yMMM("de_DE").format(role.created);
    return ListTile(
      title: Text(role.label),
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
            context, UserRole.fromSnapshot(snapshot.data.documents[index]));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userId = UserWidget.of(context).user.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Zugeordnete Firmen"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        builder: _streamBuilder,
        stream: FirestoreImpl.instance
            .collection('users')
            .document(userId)
            .collection("roles")
            .snapshots(),
      ),
    );
  }
}
