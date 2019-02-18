import 'dart:convert';

import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/utils/utils.dart';
import 'package:blaulichtplaner_app/widgets/notification_view.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:intl/intl.dart';

/// global counter for notifications ids
int notificationsCounter = 0;

class SimpleNotification {
  final String title;
  final String body;
  final String icon;
  final NotificationPayload payload;

  SimpleNotification(this.title, this.body, this.icon, this.payload);
}

class NotificationPayload {
  final String type;
  final String shiftPath;

  NotificationPayload(this.type, this.shiftPath);

  Map<String, String> toMap() {
    Map<String, String> data = {};
    data["type"] = type;
    data["shiftPath"] = shiftPath;
    return data;
  }

  NotificationPayload.fromMap(Map<String, String> data)
      : type = data["type"],
        shiftPath = data["shiftPath"];
}

class NotificationsHelper {
  final dateFormatter = DateFormat.yMd("de_DE").add_Hm();
  final Map<String, String> data;

  NotificationsHelper(this.data);

  SimpleNotification _upcomingNotification() {
    String locationLabel = data["locationLabel"];
    DateTime from = DateTime.parse(data["fromShift"]);
    DateTime to = DateTime.parse(data["toShift"]);
    String shiftPath = data["shiftPath"];

    String title = "Kommender Notdienst";
    String body =
        "Sie haben vom ${dateFormatter.format(from)} bis ${dateFormatter.format(to)} Notdienst am Standort $locationLabel";

    return SimpleNotification(
        title, body, null, NotificationPayload("upcoming", shiftPath));
  }

  SimpleNotification convertData() {
    String type = data["type"];
    switch (type) {
      case "upcoming":
        return _upcomingNotification();
      default:
        return null;
    }
  }
}

typedef void NotificationSelected(String payload);

mixin Notifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  NotificationSelected notificationSelected;

  void initNotifications(
      DocumentReference userRef, NotificationSelected notificationSelected) {
    this.notificationSelected = notificationSelected;
    _initLocalNotifications(notificationSelected);
    _initFirebaseMessaging(userRef);
    _firebaseMessaging.requestNotificationPermissions();
  }

  _initLocalNotifications(NotificationSelected notificationSelected) {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) {
      notificationSelected(payload);
    });
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) {
      notificationSelected(payload);
    });
  }

  void _initFirebaseMessaging(DocumentReference userRef) async {
    print("init messaging");
    String token = await _firebaseMessaging.getToken();
    print('gotten $token');

    await _updateTokenIfNecessary(userRef, token);

    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      try {
        print("onMessage $message");
        if (message.containsKey("aps")) {
          _showNotification(SimpleNotification(message["aps"]["alert"]["title"],
              message["aps"]["alert"]["body"], null, null));
        }
      } catch (e) {
        print(e);
      }
    }, onLaunch: (Map<String, dynamic> message) {
      print("OnLaunch: $message");
      try {
        notificationSelected(null);
      } catch (e) {
        print(e);
      }
    }, onResume: (Map<String, dynamic> message) {
      print("OnResume: $message");
      try {
        Map<String, String> data = message.containsKey("data")
            ? Map.castFrom(message['data'])
            : Map.castFrom(message);
        //_showNotification(NotificationsHelper(data).convertData());
      } catch (e) {
        print(e);
      }
    });

    _firebaseMessaging.onTokenRefresh.listen((String token) {
      _updateTokenIfNecessary(userRef, token);
    });
  }

  Future _updateTokenIfNecessary(
      DocumentReference userRef, String token) async {
    CollectionReference collection = userRef.collection('tokens');

    QuerySnapshot querySnapshot = await collection.getDocuments();

    bool tokenExits = querySnapshot.documents.firstWhere(
            (snapshot) => snapshot.data['token'] == token,
            orElse: () => null) !=
        null;

    if (!tokenExits) {
      DeviceInfo deviceInfo = await getDeviceInfo();

      collection.add({
        'token': token,
        'created': DateTime.now(),
        'model': deviceInfo.model,
        'version': deviceInfo.version,
        'name': deviceInfo.name
      });
    }
  }

  void _showNotification(SimpleNotification notification) async {
    print('show notification ${notification.title} ${notification.body}');

    try {
      var styleInformation = new BigTextStyleInformation(
        notification.body,
        contentTitle: notification.title,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'de.grundid.blaulichtplanner',
        'Dienstplaner Benachrichtigungen',
        'Benachrichtigungen über kommende Dienste und weitere Informationen',
        importance: Importance.Max,
        priority: Priority.High,
        style: AndroidNotificationStyle.BigText,
        styleInformation: styleInformation,
        icon: 'event',
        largeIcon: 'event',
        largeIconBitmapSource: BitmapSource.Drawable,
      );
      IOSNotificationDetails iOSPlatformChannelSpecifics =
          IOSNotificationDetails(presentAlert: true);
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

      String payload;
      if (notification.payload != null) {
        payload = json.encode(notification.payload.toMap());
      }

      await flutterLocalNotificationsPlugin.show(notificationsCounter++,
          notification.title, notification.body, platformChannelSpecifics,
          payload: payload);
    } catch (e) {
      print('notifications error: $e');
    }
  }
}
