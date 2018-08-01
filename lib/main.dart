import 'package:async_loader/async_loader.dart';
import 'package:blaulichtplaner_app/api_service.dart';
import 'package:blaulichtplaner_app/bid/shift_bids_view.dart';
import 'package:blaulichtplaner_app/assignment/assignment_view.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/welcome_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // debugPaintSizeEnabled = true;

  initializeDateFormatting();
  runApp(new ShiftplanApp());
}

class ShiftplanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Blaulichtplaner',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LaunchScreen(),
    );
  }
}

class LaunchScreen extends StatefulWidget {
  LaunchScreen({Key key}) : super(key: key);

  @override
  LaunchScreenState createState() => new LaunchScreenState();
}

class UserWidget extends StatelessWidget {
  final FirebaseUser _user;

  const UserWidget({Key key, FirebaseUser user})
      : _user = user,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Image.network(
        _user.photoUrl,
        width: 64.0,
        height: 64.0,
        fit: BoxFit.cover,
      ),
      Text(_user.displayName)
    ]);
  }
}

class LaunchScreenState extends State<LaunchScreen> {
  bool _initialized = false;
  FirebaseUser _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int selectedTab = 0;
  bool upcomingShifts = true;
  String currentTitle = "Blaulichtplaner";

  final UserManager userManager = UserManager.get();

  @override
  void initState() {
    super.initState();

    _auth.onAuthStateChanged.listen((user) {
      print("onAuthStateChanged: $user");
      _updateUserData(user);
    });
  }

  void _updateUserData(FirebaseUser user) async {
    if (user != null) {
      final docQuery = await Firestore.instance
          .collection("users/${user.uid}/roles")
          .getDocuments();
      userManager.initWithDocuments(user, docQuery.documents);
    } else {
      userManager.clearRoles();
    }

    setState(() {
      _user = user;
      _initialized = true;
    });
  }

  void logout() {
    _auth.signOut();
  }

  Widget _buildDialog(BuildContext context) {
    String url;
    return AlertDialog(
      title: Text("Einladungslink"),
      content: TextField(
        decoration: InputDecoration(labelText: "Link:"),
        onChanged: (value) => url = value,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Abbrechen"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text("Akzeptieren"),
          onPressed: () {
            Navigator.pop(context, url);
          },
        )
      ],
    );
  }

  void acceptInvite(BuildContext context) async {
    final inviteUrl =
        await showDialog<String>(context: context, builder: _buildDialog);
    print("invite Url: $inviteUrl");
    if (inviteUrl != null) {
      final GlobalKey<AsyncLoaderState> _asyncLoaderState =
          new GlobalKey<AsyncLoaderState>();

      final slashPos = inviteUrl.lastIndexOf("/");
      String inviteId = inviteUrl.substring(slashPos + 1);
      print("inviteId: [$inviteId]");

      InvitationRequest request = new InvitationRequest(new IOClient());
      await request.performPutRequest(_user.uid, "", inviteId, null);

/*      var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async =>
            await request.performPutRequest(_user.uid, "", inviteId, null),
        renderLoad: () => new CircularProgressIndicator(),
        renderError: ([error]) => new Text('Sorry, there was an error loading'),
        renderSuccess: ({data}) {},
      );*/
    }
    Navigator.pop(context);
  }

  Widget _createBody() {
    switch (selectedTab) {
      case 0:
        return new AssignmentView(
            employeeRoles: userManager.rolesForType("employee"),
            upcomingShifts: upcomingShifts);
      case 2:
        return new ShiftBidsView(
          workAreaRoles: userManager.rolesForType("workArea"),
          employeeRoles: userManager.rolesForType("employee"),
        );
      default:
        return Text("unkown tab id");
    }
  }

  List<Widget> _createAppBarActions() {
    switch (selectedTab) {
      case 0:
        return [
          IconButton(
              icon: Icon(Icons.rotate_90_degrees_ccw),
              onPressed: () {
                setState(() {
                  upcomingShifts = !upcomingShifts;
                });
              })
        ];
      case 2:
        return [];
      default:
        return [];
    }
  }

  String _createTitle() {
    switch (selectedTab) {
      case 0:
        {
          return upcomingShifts ? "Kommende Dienste" : "Vergangene Dienste";
        }
      case 1:
        {
          return "Dienstpläne";
        }
      case 2:
        {
          return "Offene Dienste";
        }
    }
    return "Blaulichtplaner";
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return new Container(
          color: Colors.white,
          child: new Center(
            child: new Column(
              children: <Widget>[CircularProgressIndicator()],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ));
    } else {
      if (_user == null) {
        return LoginScreen();
      } else {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(_createTitle()),
            actions: _createAppBarActions(),
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: UserWidget(user: _user),
                ),
                ListTile(
                  leading: Icon(Icons.insert_link),
                  title: Text("Einladung annehmen"),
                  onTap: () {
                    acceptInvite(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text("Logout"),
                  onTap: logout,
                )
              ],
            ),
          ),
          body: _createBody(),
          bottomNavigationBar: new BottomNavigationBar(
            currentIndex: selectedTab,
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.event_available),
                title: new Text("Schichten"),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.insert_invitation),
                title: new Text("Dienstpläne"),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.date_range),
                title: new Text("Bewerbungen"),
              )
            ],
            type: BottomNavigationBarType.fixed,
            onTap: (tapId) {
              setState(() {
                selectedTab = tapId;
              });
            },
          ),
        );
      }
    }
  }
}
