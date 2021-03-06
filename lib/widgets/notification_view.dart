import 'dart:async';

import 'package:blaulichtplaner_app/auth/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/shift/shift_view.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class NotificationView extends StatefulWidget {
  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<DocumentSnapshot> notifications = [];
  Set<DocumentReference> seenNotification = Set();
  bool empty = true;
  bool loading = true;
  Firestore _firestore = FirestoreImpl.instance;

  BlpUser user = UserManager.instance.user;
  StreamSubscription listenerSubscription;

  @override
  void initState() {
    super.initState();
    _initNotificationsListener();
  }

  _initNotificationsListener() {
    CollectionReference notificationsReference =
        _firestore.collection('notifications');

    Query query = notificationsReference;
    query = query.where("userRef", isEqualTo: user.userRef);
    query = query.where("read", isEqualTo: false);
    query = query.orderBy('mobileSend', descending: true);
    listenerSubscription = query.snapshots().listen(
      (QuerySnapshot snapshot) {
        setState(
          () {
            loading = false;
            if (snapshot != null) {
              empty = snapshot.documents.length == 0;
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

  @override
  void didUpdateWidget(NotificationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    listenerSubscription?.cancel();
    _initNotificationsListener();
  }

  Widget _itemBuilder(BuildContext context, int index) {
    DocumentSnapshot snapshot = notifications[index];
    seenNotification.add(snapshot.reference);
    Map<String, dynamic> content = Map.castFrom(snapshot.data['content']);

    DocumentReference shiftRef = snapshot.data["sourceRef"];
    DocumentReference employeeRef = snapshot.data["employeeRef"];
    String type = snapshot.data["type"];

    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(content['title']),
      ),
      subtitle: Text(content['body']),
      onTap: () {
        if (type == "upcoming") {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ShiftViewWidget(
              shiftRef: shiftRef,
              currentEmployeeRef: employeeRef,
            );
          }));
        }
      },
      trailing: Icon(
        Icons.event,
        size: 16,
      ),
    );
  }

  Widget _notificationListBuilder() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemCount: notifications.length,
      itemBuilder: _itemBuilder,
    );
  }

  Future<bool> _markReadAsRead() async {
    if (seenNotification.length > 0) {
      WriteBatch batch = _firestore.batch();
      for (DocumentReference item in seenNotification) {
        batch.updateData(item, {'read': true});
      }
      batch.commit();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Benachrichtigungen')),
      body: WillPopScope(
        onWillPop: _markReadAsRead,
        child: LoaderBodyWidget(
          loading: loading,
          empty: empty,
          fallbackText: 'Es gibt keine neuen Benachrichtigungen',
          child: _notificationListBuilder(),
        ),
      ),
    );
  }
}
