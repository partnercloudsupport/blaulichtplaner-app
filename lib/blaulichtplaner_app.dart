import 'package:blaulichtplaner_app/assignment/assignment_tab.dart';
import 'package:blaulichtplaner_app/auth/authentication.dart';
import 'package:blaulichtplaner_app/invitation/invitation_view.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_tab.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_overview_tab.dart';
import 'package:blaulichtplaner_app/utils/notifications.dart';
import 'package:blaulichtplaner_app/widgets/drawer.dart';
import 'package:blaulichtplaner_app/widgets/notification_view.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlaulichtplanerApp extends StatefulWidget {
  final Function logoutCallback;

  const BlaulichtplanerApp({Key key, this.logoutCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlaulichtPlanerAppState();
  }
}

class BlaulichtPlanerAppState extends State<BlaulichtplanerApp>
    with Notifications {
  int selectedTab = 0;
  BlpUser user;

  @override
  void initState() {
    super.initState();
    user = UserManager.instance.user;
    initNotifications(user.userRef, _notificationHandler);
  }

/*  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    initNotifications(user.userRef, _notificationHandler);
  }*/

  void _notificationHandler(String payload) {
    Navigator.popUntil(context, (Route<dynamic> route) {
      return route.isFirst;
    });
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NotificationView()));
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
