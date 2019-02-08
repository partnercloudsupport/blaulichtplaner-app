import 'package:blaulichtplaner_app/assignment/assignment_tab.dart';
import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/invitation/invitation_view.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_tab.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_overview_tab.dart';
import 'package:blaulichtplaner_app/widgets/drawer.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BlaulichtplanerApp extends StatefulWidget {
  final Function logoutCallback;

  const BlaulichtplanerApp({Key key, this.logoutCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlaulichtPlanerAppState();
  }
}

class BlaulichtPlanerAppState extends State<BlaulichtplanerApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int selectedTab = 0;
  BlpUser user;

  @override
  void initState() {
    super.initState();
    user = UserManager.instance.user;
    _initMessaging();
    _initLocalNotification();
    _firebaseMessaging.requestNotificationPermissions();
  }

  _initLocalNotification() {
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
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
            title: new Text(title),
            content: new Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text('Ok'),
                onPressed: () async {},
              )
            ],
          ),
    );
  }

  @override
  void didUpdateWidget(BlaulichtplanerApp oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _initMessaging();
  }

  void _showNotification(String title, String body) async {
    print('show notification $title $body');

    try {
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'de.grundid.blaulichtplanner', 'notification', 'description',
          importance: Importance.Max, priority: Priority.High);
      print('android platform specific done');
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      print('IOS specific done');

      var platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      print('platformChannelSpecifics specific done');

      Future result = await flutterLocalNotificationsPlugin
          .show(0, title, body, platformChannelSpecifics, payload: 'item x');
      print('message sent $result');
    } catch (e) {
      print('the errors was $e');
    }
  }

  void _initMessaging() async {
    print("init messaging");

    Firestore firestore = FirestoreImpl.instance;
    String token = await _firebaseMessaging.getToken();
    print(' gotten $token');
    CollectionReference collection =
        firestore.collection('users').document(user.uid).collection('tokens');

    QuerySnapshot querySnapshot = await collection.getDocuments();

    bool tokenExits = querySnapshot.documents.firstWhere(
            (snapshot) => snapshot.data['token'] == token,
            orElse: () => null) !=
        null;

    if (!tokenExits) {
      collection.add({'token': token, 'created': DateTime.now()});
    }

    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      try {
        print("something else: ${message.keys}");
        Map<String, dynamic> notification =
            Map.castFrom(message['notification']);
        print('this is the $notification');

        _showNotification(notification['title'], notification['body']);
      } catch (e) {
        print(e);
      }
    });

    _firebaseMessaging.onTokenRefresh.listen((String token) {
      print(' output $token');
    });
  }

  Widget _createWidget(
      BlpUser user, BottomNavigationBar bottomNavigationBar, Widget drawer) {
    switch (selectedTab) {
      case 0:
        return AssignmentTabWidget(
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          user: user,
        );
      case 1:
        return ShiftplanOverviewTabWidget(
          user: user,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
        );
      case 2:
        return ShiftVotesTabWidget(
          user: user,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
        );
      default:
        return Text("unkown tab id");
    }
  }

  Widget _createDrawer(BlpUser user) {
    return DrawerWidget(
      user: user,
      invitationCallback: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => InvitationScreen(
                  onSaved: () {
                    // TODO user.updateUserData(user);
                  },
                ),
          ),
        );
      },
      logoutCallback: widget.logoutCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    BottomNavigationBar bottomNavigationBar = BottomNavigationBar(
      currentIndex: selectedTab,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.event_available),
          title: Text("Schichten"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.table_chart),
          title: Text('Dienstpäne'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.date_range),
          title: Text("Bewerbungen"),
        )
      ],
      type: BottomNavigationBarType.fixed,
      onTap: (tapId) {
        setState(() {
          selectedTab = tapId;
        });
      },
    );
    return _createWidget(user, bottomNavigationBar, _createDrawer(user));
  }
}
