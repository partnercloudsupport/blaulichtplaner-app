import 'package:blaulichtplaner_app/about_widget.dart';
import 'package:blaulichtplaner_app/roles_widget.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  final FirebaseUser user;
  final Function logoutCallback;
  final Function invitationCallback;
  final List<Role> employeeRoles;

  DrawerWidget({
    Key key,
    @required this.user,
    @required this.logoutCallback,
    @required this.invitationCallback,
    @required this.employeeRoles,
  }) : super(key: key);

  Widget _buildImage() {
    if (user.photoUrl != null) {
      return CircleAvatar(backgroundImage: NetworkImage(user.photoUrl));
    } else {
      return Icon(Icons.account_circle);
    }
  }

  @override
  build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: _buildImage(),
            title: Text(user.displayName ?? 'Profil'),
          ),
          ListTile(
            leading: Icon(Icons.insert_link),
            title: Text("Einladungen"),
            onTap: invitationCallback,
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Zugeordnete Firmen"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RolesScreen()));
            },
          ),
          Divider(),
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
            onTap: logoutCallback,
          ),
        ],
      ),
    );
  }
}
