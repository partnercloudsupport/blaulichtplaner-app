import 'package:blaulichtplaner_app/api_service.dart';
import 'package:blaulichtplaner_app/location_votes/location_votes_view.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_view.dart';
import 'package:blaulichtplaner_app/assignment/assignment_view.dart';
import 'package:blaulichtplaner_app/registration_widget.dart';
import 'package:blaulichtplaner_app/roles_widget.dart';
import 'package:blaulichtplaner_app/settings_widget.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_view.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/welcome_widget.dart';
import 'package:blaulichtplaner_app/about_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

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
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
    );
  }
}

class LaunchScreen extends StatefulWidget {
  LaunchScreen({Key key}) : super(key: key);

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

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

  @override
  build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
            title: Text(user.displayName),
          ),
          ListTile(
            leading: Icon(Icons.insert_link),
            title: Text("Einladung annehmen"),
            onTap: invitationCallback,
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Zugeordnete Standorte"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RolesScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.timelapse),
            title: Text("Zeiträume"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LocationVotesView(employeeRoles: employeeRoles)));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Einstellungen"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
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

class LaunchScreenState extends State<LaunchScreen> {
  bool _initialized = false;
  bool _registered = false;
  FirebaseUser _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int selectedTab = 0;
  bool upcomingShifts = true;
  String currentTitle = "Blaulichtplaner";
  FilterOptions _selectedFilterOption = FilterOptions.withoutBid;
  bool _selectDate = false;
  DateTime _initialDate;
  DateTime _selectedDate;

  final UserManager userManager = UserManager.get();

  @override
  void initState() {
    super.initState();
    _initialDate = _selectedDate = DateTime.now();

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
      case 1:
        return ShiftplanView(
          employeeRoles: userManager.rolesForType("employee"),
        );
      case 2:
        return ShiftVotesView(
          workAreaRoles: userManager.rolesForType("workArea"),
          employeeRoles: userManager.rolesForType("employee"),
          filter: _selectedFilterOption,
          selectedDate: _selectDate ? _selectedDate : null,
        );
      default:
        return Text("unkown tab id");
    }
  }

  List<Widget> _createAppBarActions() {
    switch (selectedTab) {
      case 0:
        return <Widget>[
          IconButton(
              icon: Icon(Icons.rotate_90_degrees_ccw),
              onPressed: () {
                setState(() {
                  upcomingShifts = !upcomingShifts;
                });
              })
        ];
      case 2:
        return <Widget>[
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectDate = !_selectDate;
              });
            },
          ),
          PopupMenuButton(
            onSelected: (FilterOptions val) {
              setState(() {
                _selectedFilterOption = val;
              });
            },
            child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Icon(Icons.filter_list)),
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<FilterOptions>>[
                  PopupMenuItem(
                    child: Text(
                      'Filtern',
                      style: TextStyle(color: Colors.black),
                    ),
                    enabled: false,
                  ),
                  PopupMenuItem<FilterOptions>(
                      value: FilterOptions.withoutBid,
                      child: Row(
                        children: <Widget>[
                          Radio(
                            onChanged: (val) {
                              setState(() {
                                _selectedFilterOption = val;
                              });
                            },
                            groupValue: _selectedFilterOption,
                            value: FilterOptions.withoutBid,
                          ),
                          Text('Dienste ohne Bewerbung'),
                          //Icon(Icons.help_outline),
                        ],
                      )),
                  PopupMenuItem(
                      value: FilterOptions.withBid,
                      child: Row(
                        children: <Widget>[
                          Radio(
                            onChanged: (val) {
                              setState(() {
                                _selectedFilterOption = val;
                              });
                            },
                            groupValue: _selectedFilterOption,
                            value: FilterOptions.withBid,
                          ),
                          Text('Beworbene Dienste'),
                          //Icon(Icons.done_outline),
                        ],
                      )),
                  PopupMenuItem(
                      value: FilterOptions.notInterested,
                      child: Row(
                        children: <Widget>[
                          Radio(
                            onChanged: (val) {
                              setState(() {
                                _selectedFilterOption = val;
                              });
                            },
                            groupValue: _selectedFilterOption,
                            value: FilterOptions.notInterested,
                          ),
                          Text('Abgelehnte Dienste'),
                          //Icon(Icons.not_interested),
                        ],
                      )),
                ],
          ),
        ];
      default:
        return [];
    }
  }

  String _createShiftBidTitle() {
    switch (_selectedFilterOption) {
      case FilterOptions.withoutBid:
        return "Offene Dienste";
      case FilterOptions.withBid:
        return "Beworbene Diente";
      case FilterOptions.notInterested:
      default:
        return "Abgelehnte Dienste";
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
          return _createShiftBidTitle();
        }
    }
    return "Blaulichtplaner";
  }

  Widget _createDateNavigation() {
    if (_selectDate && selectedTab == 2) {
      return PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (_selectedDate
                            .subtract(Duration(days: 1))
                            .compareTo(_initialDate) >=
                        0)
                    ? () {
                        setState(() {
                          _selectedDate = (_selectedDate
                                      .subtract(Duration(days: 1))
                                      .compareTo(_initialDate) >=
                                  0)
                              ? _initialDate
                              : _selectedDate.subtract(Duration(days: 1));
                        });
                      }
                    : null,
                color: Colors.white,
              ),
              FlatButton(
                child: Text(
                  DateFormat.yMMMd("de_DE").format(_selectedDate),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  showDatePicker(
                      context: context,
                      firstDate: _initialDate,
                      lastDate: DateTime.now().add(Duration(days: 356)),
                      initialDate: _selectedDate).then((DateTime date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  });
                },
              ),
              IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(Duration(days: 1));
                    });
                  },
                  color: Colors.white)
            ],
          ));
    } else {
      return null;
    }
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_createTitle()),
        actions: _createAppBarActions(),
        bottom: _createDateNavigation(),
      ),
      drawer: DrawerWidget(
        user: _user,
        invitationCallback: () {
          acceptInvite(context);
        },
        logoutCallback: () {
          logout();
        },
        employeeRoles: userManager.rolesForType("employee"),
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
        return _buildHomeScreen(context);
      }
    }
  }
}
