import 'package:blaulichtplaner_app/auth/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:flutter/material.dart';

class Invitation extends StatelessWidget {
  final LoadableWrapper<InvitationModel> loadableInvitationModel;
  final Function(LoadableWrapper<InvitationModel> loadableInvitationModel)
      onAccept;

  const Invitation(
      {Key key,
      @required this.loadableInvitationModel,
      @required this.onAccept})
      : super(key: key);

  _buildColumn() {
    List<Widget> widgets = [
      ListTile(
        contentPadding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
        title:
            Text('Eingeladen von: ${loadableInvitationModel.data.invitedBy}'),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Wrap(
          children: <Widget>[
            Chip(
              label:
                  Text('Firma: ${loadableInvitationModel.data.companyLabel}'),
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
          loading: loadableInvitationModel.loading,
          padding: EdgeInsets.all(14.0),
          builder: (BuildContext context) {
            return ButtonTheme.bar(
              child: ButtonBar(
                alignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text('Akzeptieren'),
                    onPressed: () {
                      onAccept(loadableInvitationModel);
                    },
                  )
                ],
              ),
            );
          })
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

class InvitationList extends StatefulWidget {
  final BlpUser user;

  InvitationList({Key key, @required this.user}) : super(key: key);

  @override
  _InvitationListState createState() => _InvitationListState();
}

class _InvitationListState extends State<InvitationList> {
  _acceptInvitation(
      LoadableWrapper<InvitationModel> loadableInvitationModel) async {
    setState(() {
      loadableInvitationModel.loading = true;
    });

    ActionResult result = await InvitationAccept(FirestoreImpl.instance,
            ActionContext(UserManager.instance.user, null, null))
        .performAction(
            InvitationAction(loadableInvitationModel.data, widget.user));
    if (result.ok) {
      UserManager.instance.updateRoles();
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
    ));
  }

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
          loadableInvitationModel: LoadableWrapper(
              InvitationModel.fromSnapshot(snapshot.data.documents[index])),
          onAccept: _acceptInvitation,
        );
      },
      itemCount: snapshot.data.documents.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreImpl.instance
          .collection('invitations')
          .where('email', isEqualTo: widget.user.email)
          .where('accepted', isEqualTo: false)
          .snapshots(),
      builder: _streamBuilder,
    );
  }
}

class InvitationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BlpUser user = UserManager.instance.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Einladungslink'),
      ),
      body: InvitationList(
        user: user,
      ),
    );
  }
}
