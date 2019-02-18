import 'dart:convert';

//import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

/*
mixin LocalNotifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidRecieveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    print("onSelectNotification: $payload");
    
  }

    void showNotification(SimpleNotification notification) async {
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


  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {
          ("location notification received: $id, $payload");
        
  }



}*/