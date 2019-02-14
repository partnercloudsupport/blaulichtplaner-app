import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class Preferences extends StatefulWidget {
  @override
  PreferencesState createState() {
    return new PreferencesState();
  }
}

class PreferencesState extends State<Preferences> {
  BlpUser user = UserManager.instance.user;
  bool emailNotificationValueState;
  bool notificationsValueState;
  DocumentSnapshot settingsSnapShot;

  @override
  void initState() {
    super.initState();
    _getDocumentReference();
  }

  _getFireBaseUpdates() async {}

  _getDocumentReference({bool emailValue, bool notificationsValue}) async {
    Firestore firestore = FirestoreImpl.instance;
    DocumentReference notificationsReference = firestore
        .collection('users')
        .document(user.uid)
        .collection('settings')
        .document('notifications');
    DocumentSnapshot snapshot = await notificationsReference.document;

    if (emailValue != null) {
      notificationsReference.update({'emailNotifications': emailValue});
    }
    if (notificationsValue != null) {
      notificationsReference.update({'notifications': notificationsValue});
    }

    notificationsReference.snapshots.listen((DocumentSnapshot snapshot) {
      setState(() {
        settingsSnapShot = snapshot;
        emailNotificationValueState = settingsSnapShot.data['emailNotifications'];
        notificationsValueState = settingsSnapShot.data['notifications'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Benachrichtigungen')),
      body: LoaderWidget(
        padding: EdgeInsets.all(0),
        loading: settingsSnapShot == null,
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Benachrichtigung: '),
                    subtitle: Text('Benachrichtigung via Mobile phone'),
                    trailing: Checkbox(
                        tristate: true,
                        value: notificationsValueState,
                        onChanged: (value) {
                          _getDocumentReference(notificationsValue: !notificationsValueState);
                        }),
                  ),
                  ListTile(
                    title: Text('Email-Benachrichtigung: '),
                    subtitle: Text('Benachrichtigung via Email'),
                    trailing: Checkbox(
                      tristate: true,
                        value:  emailNotificationValueState,
                        onChanged: (value) {
                          _getDocumentReference(emailValue: !emailNotificationValueState);
                        }),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
