import 'dart:async';

import 'package:blaulichtplaner_app/assignment/assignment_tab.dart';
import 'package:blaulichtplaner_app/auth/authentication.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_tab.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_overview_tab.dart';
import 'package:blaulichtplaner_app/widgets/connection_widget.dart';
import 'package:blaulichtplaner_app/widgets/drawer.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class BlaulichtplanerApp extends StatefulWidget {
  final Function logoutCallback;

  const BlaulichtplanerApp({Key key, this.logoutCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlaulichtPlanerAppState();
  }
}

class BlaulichtPlanerAppState extends State<BlaulichtplanerApp> {
  int selectedTab = 0;
  BlpUser user;
  StreamSubscription _connectivity;
  ConnectivityResult _connectivityResult;

  @override
  void initState() {
    super.initState();
    user = UserManager.instance.user;
    _connectivity = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
  }

  @override
  void dispose() {
    _connectivity?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    user = UserManager.instance.user;
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
          title: Text('Dienstpläne'),
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
    return ConnectionStateWidget(
        connectivityResult: _connectivityResult,
        child: _createWidget(user, bottomNavigationBar, _createDrawer(user)));
  }
}
