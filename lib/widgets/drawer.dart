import 'package:blaulichtplaner_app/about_widget.dart';
import 'package:blaulichtplaner_app/invitation/invitation_view.dart';
import 'package:blaulichtplaner_app/roles_widget.dart';
import 'package:blaulichtplaner_app/widgets/notification_view.dart';
import 'package:blaulichtplaner_app/widgets/project_id.dart';
import 'package:blaulichtplaner_app/widgets/settings.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  final BlpUser user;
  final Function logoutCallback;

  DrawerWidget({Key key, @required this.user, @required this.logoutCallback})
      : super(key: key);

  Widget _buildImage() {
    if (user.photoURL != null) {
      return CircleAvatar(backgroundImage: NetworkImage(user.photoURL));
    } else {
      return Icon(Icons.account_circle);
    }
  }

  @override
  build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/blp-logo.png",
                    width: 64,
                  ),
                ),
                Text(
                  "Blaulichtplaner",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                )
              ],
            ),
          ),
          ListTile(
            leading: _buildImage(),
            title: Text(user.displayName ?? 'Profil'),
          ),
          ListTile(
            leading: Icon(Icons.insert_link),
            title: Text("Einladungen"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => InvitationScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Zugeordnete Firmen"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RolesScreen(
                          companyRoles: user.companyEmployeeRoles())));
            },
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text("Einstellungen"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsView()));
              }),
          ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Benachrichtigungen"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationView()));
              }),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Über die App"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              logoutCallback();
            },
          ),
          Divider(),
          Center(child: ProjectIdText())
        ],
      ),
    );
  }
}
