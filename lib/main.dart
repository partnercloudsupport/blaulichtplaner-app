import 'package:blaulichtplaner_app/api_service.dart';
import 'package:blaulichtplaner_app/bid/shift_bids_view.dart';
import 'package:blaulichtplaner_app/assignment/assignment_view.dart';
import 'package:blaulichtplaner_app/registration_widget.dart';
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
  runApp(ShiftplanApp());
}

class ShiftplanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blaulichtplaner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LaunchScreen(),
    );
  }
}

class LaunchScreen extends StatefulWidget {
  LaunchScreen({Key key}) : super(key: key);

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  bool _initialized = false;
  bool _registered = false;
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
      _isRegistered(user);
    });
  }

  void _updateUserData(FirebaseUser user) async {
    userManager.clearRoles();
    if (user != null) {
      final docQuery = await Firestore.instance
          .collection("users/${user.uid}/roles")
          .getDocuments();

      userManager.initWithDocuments(user, docQuery.documents);
    }

    setState(() {
      _user = user;
      _initialized = true;
    });
  }

  void _isRegistered(FirebaseUser user) async {
    if (user != null) {
      final doc =
          await Firestore.instance.collection("users").document(user.uid).get();
      setState(() {
        _registered = doc.exists;
      });
    }
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
      final slashPos = inviteUrl.lastIndexOf("/");
      String inviteId = inviteUrl.substring(slashPos + 1);
      print("inviteId: [$inviteId]");

      InvitationRequest request = InvitationRequest(IOClient());
      await request.performPutRequest(_user.uid, "", inviteId, null);
    }
    _updateUserData(_user);
    Navigator.pop(context);
  }

  Widget _createBody() {
    switch (selectedTab) {
      case 0:
        return AssignmentView(
            employeeRoles: userManager.rolesForType("employee"),
            upcomingShifts: upcomingShifts);
      case 2:
        return ShiftBidsView(
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
      return Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: <Widget>[CircularProgressIndicator()],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ));
    } else {
      if (_user == null) {
        return LoginScreen();
      } else if (!_registered) {
        return RegistrationScreen(
            user: _user,
            successCallback: () {
              setState(() {
                _registered = true;
              });
            });
      } else {
        //return RegistrationScreen(user: _user);
        return Scaffold(
          appBar: AppBar(
            title: Text(_createTitle()),
            actions: _createAppBarActions(),
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(_user.photoUrl)),
                  title: Text(_user.displayName),
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
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedTab,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.event_available),
                title: Text("Schichten"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insert_invitation),
                title: Text("Dienstpläne"),
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
          ),
        );
      }
    }
  }
}
