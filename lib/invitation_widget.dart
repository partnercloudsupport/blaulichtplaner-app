import 'package:blaulichtplaner_app/api_service.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class InvitationInfo extends StatefulWidget {
  final String inviteUrl;

  const InvitationInfo({Key key, @required this.inviteUrl}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return InvitationInfoState();
  }
}

class InvitationInfoState extends State<InvitationInfo> {
  bool _initialized = false;
  String _companyLabel = '';
  String _locationLabel = '';
  String _inviteUrl = '';

  _loadInfo() async {
    try {
      CollectionReference invitationsRef =
          Firestore.instance.collection('invitations');
      int inviteIndex = _inviteUrl?.lastIndexOf("/");
      String inviteId = _inviteUrl?.substring(inviteIndex + 1);
      if (inviteId != null && inviteId?.length > 8) {
        DocumentSnapshot snapshot =
            await invitationsRef.document(inviteId).get();
        if (snapshot.exists) {
          setState(() {
            _initialized = true;
            _companyLabel = snapshot.data["companyLabel"] ?? "Unbekannte Firma";
            _locationLabel =
                snapshot.data["locationLabel"] ?? "Unbekannter Standort";
          });
        }
      } else {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(InvitationInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inviteUrl != _inviteUrl) {
      setState(() {
        _inviteUrl = widget.inviteUrl;
        _initialized = false;
      });
      _loadInfo();
    }
  }

  Widget _buildInfoBox() {
    if (_inviteUrl == '' || _inviteUrl == null) {
      return Text('Fügen Sie einen Link ein');
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(_companyLabel),
                  ),
                  Wrap(
                    children: <Widget>[
                      Chip(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black.withAlpha(0x1f),
                                width: 1.0,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(28.0)),
                        label: Text(_locationLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: LoaderWidget(
        loading: !_initialized,
        child: _buildInfoBox(),
      ),
    );
  }
}

class InvitationForm extends StatefulWidget {
  final Function onSaved;
  final FirebaseUser user;

  const InvitationForm({Key key, this.onSaved, this.user}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return InvitationFormState();
  }
}

class InvitationFormState extends State<InvitationForm> {
  bool _saving = false;
  String _inviteUrl;
  final _formKey = GlobalKey<FormState>();
  TextEditingController linkController;

  _listener() {
    setState(() {
      _inviteUrl = linkController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    linkController = TextEditingController()..addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    linkController
      ..removeListener(_listener)
      ..dispose();
  }

  Widget _buildSaveButton() {
    return RaisedButton(
      color: Colors.blue,
      child: Text('Akzeptieren'),
      onPressed: () async {
        if (_formKey.currentState.validate()) {
          try {
            setState(() {
              _saving = true;
            });
            String inviteId =
                _inviteUrl.substring(_inviteUrl.lastIndexOf("/") + 1);
            print("inviteId: [$inviteId]");
            InvitationRequest request = InvitationRequest(IOClient());
            await request.performPutRequest(
              widget.user.uid,
              '',
              inviteId,
              null,
            );
            Navigator.pop(context);
            widget.onSaved();
          } catch (e) {
            print(e.toString());
            Scaffold.of(context, nullOk: true).showSnackBar(
                SnackBar(content: Text('Einladungslink ungültig')));
            setState(() {
              _saving = false;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: linkController,
              decoration: InputDecoration(helperText: 'Einladungslink'),
              validator: (String val) {
                if (val.isEmpty) {
                  return 'Bitte Link einfügen';
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[Text('Infos')],
              ),
            ),
            InvitationInfo(
              inviteUrl: _inviteUrl,
            ),
            LoaderWidget(
              loading: _saving,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Abbrechen'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildSaveButton(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class InvitationScreen extends StatelessWidget {
  final Function onSaved;
  final FirebaseUser user;

  const InvitationScreen({
    Key key,
    @required this.onSaved,
    @required this.user,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einladungslink'),
        leading: CloseButton(),
      ),
      body: SingleChildScrollView(
        child: InvitationForm(onSaved: onSaved, user: user),
      ),
    );
  }
}
