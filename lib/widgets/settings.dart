import 'package:blaulichtplaner_app/auth/change_password_widget.dart';
import 'package:blaulichtplaner_app/widgets/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Benachrichtigungen"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Preferences()));
            },
          ),
          ListTile(
            title: Text("Passwort ändern"),
            onTap: () async {
              FirebaseAuth auth = FirebaseAuth.instance;
              FirebaseUser user = await auth.currentUser();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordWidget(
                        user: user,
                      ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
