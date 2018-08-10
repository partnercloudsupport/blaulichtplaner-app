import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Row(children: <Widget>[
                Padding(
                  child: Icon(Icons.settings),
                  padding: EdgeInsets.only(right: 8.0),
                ),
                Text("Einstellungen")
              ]),
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.notifications_active),
                    text: 'Benachrichtigungen',
                  ),
                  Tab(icon: Icon(Icons.account_circle), text: 'Account'),
                  Tab(icon: Icon(Icons.help_outline), text: 'Feedback')
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                new SingleChildScrollView(
                  child: Center(
                    child: Text('Hi'),
                  ),
                ),
                new SingleChildScrollView(
                  child: Center(
                    child: Text('Hi'),
                  ),
                ),
              ],
            )));
  }
}