import 'dart:async';

import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class NotificationView extends StatefulWidget {
  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<DocumentSnapshot> notifications = [];
  bool empty = true;
  bool loading = true;

  BlpUser user = UserManager.instance.user;
  CollectionReference notificationsReference;
  StreamSubscription listenerSubscription;

  @override
  void initState() {
    super.initState();
    notificationsReference = _getDocumentReference();
  }

  CollectionReference _getDocumentReference() {
    Firestore firestore = FirestoreImpl.instance;
    CollectionReference notificationsReference = firestore
        .collection('users')
        .document(user.uid)
        .collection('notifications');

    _updateNotificationListener(notificationsReference);
    return notificationsReference;
  }

  _updateNotificationListener(CollectionReference reference) {
    listenerSubscription = reference.snapshots().listen(
      (QuerySnapshot snapshot) {
        setState(
          () {
            if (snapshot != null) {
              empty = false;
              loading = false;
              notifications = snapshot.documents;
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    listenerSubscription?.cancel();
  }

  Widget _notificationListBuilder() {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, i) {

        DocumentSnapshot snapshot = notifications[i];
        Map<String, dynamic> content = Map.castFrom(snapshot.data['content']);
        bool read = snapshot.data['read'];

        return ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(content['title']),
          ),
          subtitle: Text(content['body']),
          trailing: read
              ? Icon(Icons.check_circle, size: 16,)
              : Icon(Icons.check_circle_outline, size: 16,),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Benachrichtigungen')),
      body: LoaderBodyWidget(
        loading: loading,
        empty: empty,
        fallbackWidget: Text('Es gibt keine neuen Benachrichtigungen'),
        child: _notificationListBuilder(),
      ),
    );
  }
}
