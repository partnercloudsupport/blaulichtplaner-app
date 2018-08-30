import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text("Einstellungen"),
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.notifications_active),
                    text: 'Benachrichtigungen',
                  ),
                  Tab(
                    icon: Icon(Icons.account_circle),
                    text: 'Account',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                SingleChildScrollView(
                  child: Center(
                    child: Text('Hi'),
                  ),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: Text('Hi'),
                  ),
                ),
              ],
            )));
  }
}
