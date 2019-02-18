import 'package:blaulichtplaner_app/assignment/assignment_tab.dart';
import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/invitation/invitation_view.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_tab.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_overview_tab.dart';
import 'package:blaulichtplaner_app/utils/utils.dart';
import 'package:blaulichtplaner_app/widgets/drawer.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:blaulichtplaner_app/utils/notifications.dart';

class BlaulichtplanerApp extends StatefulWidget {
  final Function logoutCallback;

  const BlaulichtplanerApp({Key key, this.logoutCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlaulichtPlanerAppState();
  }
}

class BlaulichtPlanerAppState  extends State<BlaulichtplanerApp>  { //with LocalNotifications
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  int selectedTab = 0;
  BlpUser user;

  @override
  void initState() {
    super.initState();
    user = UserManager.instance.user;
   // _initMessaging();
   // initLocalNotification();
    //_firebaseMessaging.requestNotificationPermissions();
  }


  @override
  void didUpdateWidget(BlaulichtplanerApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    //_initMessaging();
  }


  void _initMessaging() async {
    print("init messaging");

    Firestore firestore = FirestoreImpl.instance;
    String token = await _firebaseMessaging.getToken();
    print(' gotten $token');

    await _updateTokenIfNecessary(firestore, token);

    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      try {
        print("onMessage $message");
        Map<String, String> data = message.containsKey("data")
            ? Map.castFrom(message['data'])
            : Map.castFrom(message);
     //   showNotification(SimpleNotification(message["aps"]["alert"]["title"], message["aps"]["alert"]["body"],
     //    null, null));
      } catch (e) {
        print(e);
      }
    }, onLaunch: (Map<String, dynamic> message) {
      print("OnLaunch: $message");
      try {
        Map<String, String> data = message.containsKey("data")
            ? Map.castFrom(message['data'])
            : Map.castFrom(message);
        //_showNotification(NotificationsHelper(data).convertData());
      } catch (e) {
        print(e);
      }


    }, onResume: (Map<String, dynamic> message) {
      print("OnResume: $message");
     // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Preferences()));
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
      _updateTokenIfNecessary(firestore, token);
    });
  }

  Future _updateTokenIfNecessary(Firestore firestore, String token) async {
    CollectionReference collection =
        firestore.collection('users').document(user.uid).collection('tokens');

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
