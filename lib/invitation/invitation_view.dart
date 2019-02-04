import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/invitation/invitation_model.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:flutter/material.dart';

class Invitation extends StatefulWidget {
  final InvitationModel invitationModel;

  const Invitation({Key key, @required this.invitationModel}) : super(key: key);

  @override
  State createState() {
    return _InvitationState();
  }
}

class _InvitationState extends State<Invitation> {
  bool _saving = false;
  _saveInvitation() async {
    setState(() {
      _saving = true;
    });
    try {
      BlpUser user = UserWidget.of(context).user;

      DocumentReference userRef =
          FirestoreImpl.instance.collection('users').document(user.uid);
      QuerySnapshot snapshot = await userRef
          .collection('roles')
          .where('reference', isEqualTo: widget.invitationModel.employeeRef)
          .where('type', isEqualTo: 'employee')
          .getDocuments();
      if (snapshot.documents.isEmpty) {
        WriteBatch batch = FirestoreImpl.instance.batch();
        Map<String, dynamic> roleData = {};
        roleData['role'] = 'user';
        roleData['type'] = 'employee';
        roleData['created'] = DateTime.now();
        roleData['reference'] = widget.invitationModel.employeeRef;
        roleData['companyRef'] = widget.invitationModel.companyRef;
        roleData['companyLabel'] = widget.invitationModel.companyLabel;

        Map<String, Object> invitationData = {};
        invitationData["accepted"] = true;
        invitationData["acceptedOn"] = DateTime.now();

        Map<String, Object> employeeData = {};
        employeeData["userRef"] = userRef;
        employeeData["invitationPending"] = false;

        batch
          ..setData(userRef.collection('roles').document(), roleData)
          ..updateData(widget.invitationModel.selfRef, invitationData)
          ..updateData(widget.invitationModel.employeeRef, employeeData);

        await batch.commit();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Einladung erfolgreich akzeptiert'),
        ));
      } else {
        Map<String, Object> invitationData = {};
        invitationData["accepted"] = true;
        invitationData["acceptedOn"] = DateTime.now();
        widget.invitationModel.selfRef.update(invitationData);
        print("user has already employee role");
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              'Sie sind wurden schon einmal zu diesem Standort eingeladen.'),
        ));
      }
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Einladung konnte nicht akzeptiert werden.'),
      ));
    }
  }

  _buildColumn() {
    List<Widget> widgets = [
      ListTile(
        contentPadding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
        title: Text('Eingeladen von: ${widget.invitationModel.invitedBy}'),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Wrap(
          children: <Widget>[
            Chip(
              label: Text('Firma: ${widget.invitationModel.companyLabel}'),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.black.withAlpha(0x1f),
                    width: 1.0,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(28.0),
              ),
            ),
          ],
        ),
      ),
      LoaderWidget(
        loading: _saving,
        padding: EdgeInsets.all(14.0),
        child: ButtonTheme.bar(
          child: ButtonBar(
            alignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                child: Text('Akzeptieren'),
                onPressed: _saveInvitation,
              )
            ],
          ),
        ),
      )
    ];
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: _buildColumn(),
    );
  }
}

class InvitationScreen extends StatelessWidget {
  final Function onSaved;

  const InvitationScreen({
    Key key,
    @required this.onSaved,
  }) : super(key: key);

  Widget _streamBuilder(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.data.documents.isEmpty) {
      return Center(child: Text('Sie haben keine neuen Einladungen'));
    }

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Invitation(
          invitationModel:
              InvitationModel.fromSnapshot(snapshot.data.documents[index]),
        );
      },
      itemCount: snapshot.data.documents.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    BlpUser user = UserWidget.of(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Einladungslink'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreImpl.instance
            .collection('invitations')
            .where('email', isEqualTo: user.email)
            .where('accepted', isEqualTo: false)
            .snapshots(),
        builder: _streamBuilder,
      ),
    );
  }
}
