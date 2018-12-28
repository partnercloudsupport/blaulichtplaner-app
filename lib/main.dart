import 'package:blaulichtplaner_app/assignment/assignment_view.dart';
import 'package:blaulichtplaner_app/invitation/invitation_view.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote_editor.dart';
import 'package:blaulichtplaner_app/location_votes/location_votes_view.dart';
import 'package:blaulichtplaner_app/login/google_registration_widget.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_view.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_overview.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/login/welcome_widget.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:blaulichtplaner_app/widgets/date_navigation.dart';
import 'package:blaulichtplaner_app/widgets/drawer.dart';

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
      debugShowCheckedModeBanner: true,
    );
  }
}

class LaunchScreen extends StatefulWidget {
  LaunchScreen({Key key}) : super(key: key);

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class FilterMenu extends StatefulWidget {
  final FilterOptions initialValue;
  final Function onChanged;

  const FilterMenu({
    Key key,
    @required this.initialValue,
    @required this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FilterMenuState(initialValue);
  }
}

class FilterMenuState extends State<FilterMenu> {
  FilterOptions _selectedFilterOption;
  FilterMenuState(this._selectedFilterOption);
  void _onChanged(val) {
    setState(() {
      _selectedFilterOption = val;
    });
    widget.onChanged(_selectedFilterOption);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile(
            groupValue: _selectedFilterOption,
            onChanged: _onChanged,
            value: FilterOptions.allShifts,
            title: Text('Alle Dienste'),
          ),
          RadioListTile(
            groupValue: _selectedFilterOption,
            onChanged: _onChanged,
            value: FilterOptions.withoutBid,
            title: Row(
              children: <Widget>[
                Text('Dienste ohne Bewerbung'),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.help,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          RadioListTile(
            groupValue: _selectedFilterOption,
            onChanged: _onChanged,
            value: FilterOptions.withBid,
            title: Row(
              children: <Widget>[
                Text('Dienste mit Bewerbung'),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          RadioListTile(
            groupValue: _selectedFilterOption,
            onChanged: _onChanged,
            value: FilterOptions.notInterested,
            title: Row(
              children: <Widget>[
                Text('Abgelehnte Dienste'),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
    );
  }
}

class LaunchScreenState extends State<LaunchScreen> {
  bool _initialized = false;
  bool _registered = true;
  FirebaseUser _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int selectedTab = 0;
  bool upcomingShifts = true;
  bool upcomingPlans = true;
  String currentTitle = "Blaulichtplaner";
  FilterOptions _selectedFilterOption = FilterOptions.allShifts;
  bool _selectDate = false;
  DateTime _initialDate;
  DateTime _selectedDate;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  bool _hasEmployeeRoles() =>
      userManager.rolesForType("employee") != null &&
      userManager.rolesForType("employee").isNotEmpty;

  void _logout() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      // TODO check if providerId should be google. the framework returns "firebase" atm
      if (user.providerId == "firebase") {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email'],
        );
        await googleSignIn.disconnect();
      }
    }
    await _auth.signOut();
  }

  Widget _createBody() {
    switch (selectedTab) {
      case 0:
        return AssignmentView(
            employeeRoles: userManager.rolesForType("employee"),
            upcomingShifts: upcomingShifts);
      case 1:
        return ShiftplanOverview(
          employeeRoles: userManager.rolesForType("employee"),
        );
      case 2:
        return LocationVotesView(
          employeeRoles: userManager.rolesForType("employee"),
        );
      case 3:
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

      case 1:
        return <Widget>[
          IconButton(
            icon: Icon(Icons.rotate_90_degrees_ccw),
            onPressed: () {
              setState(() {
                upcomingPlans = !upcomingPlans;
              });
            },
          )
        ];
      case 2:
        return <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _hasEmployeeRoles()
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return LocationVoteEditor(
                            employeeRoles: userManager.rolesForType("employee"),
                            userVote: UserVote(),
                          );
                        },
                      ),
                    );
                  }
                : null,
          )
        ];
      case 3:
        return <Widget>[
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectDate = !_selectDate;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => FilterMenu(
                        onChanged: (val) {
                          setState(() {
                            _selectedFilterOption = val;
                          });
                        },
                        initialValue: _selectedFilterOption,
                      ));
            },
          )
        ];
      default:
        return [];
    }
  }

  String _createShiftBidTitle() {
    switch (_selectedFilterOption) {
      case FilterOptions.allShifts:
        return "Alle Dienste";
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
        return upcomingShifts ? "Kommende Dienste" : "Vergangene Dienste";
      case 1:
        return upcomingPlans
            ? "Aktuelle Dienstpläne"
            : "Vergangene Dienstpläne";
      case 2:
        return "Zeiträume";
      case 3:
        return _createShiftBidTitle();
      default:
        return "Blaulichtplaner";
    }
  }

  Widget _createDateNavigation() {
    if (_selectDate && selectedTab == 3) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: DateNavigation(
          initialValue: _selectedDate,
          onChanged: (DateTime date) {
            _selectedDate = date;
          },
        ),
      );
    } else {
      return null;
    }
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_createTitle()),
        actions: _createAppBarActions(),
        bottom: _createDateNavigation(),
      ),
      drawer: DrawerWidget(
        user: _user,
        invitationCallback: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => InvitationScreen(
                    user: _user,
                    onSaved: () {
                      _updateUserData(_user);
                    },
                  ),
            ),
          );
        },
        logoutCallback: _logout,
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
            icon: Icon(Icons.table_chart),
            title: Text('Dienstpäne'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timelapse),
            title: Text("Zeiträume"),
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
            _selectDate = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderBodyWidget(
      loading: !_initialized,
      child: (_registered)
          ? _buildHomeScreen(context)
          : GoogleRegistrationScreen(
              user: _user,
              successCallback: () {
                setState(() {
                  _registered = true;
                });
              }),
      empty: _user == null,
      fallbackWidget: WelcomeScreen(
        successCallback: () {
          setState(() {
            _registered = true;
          });
        },
      ),
    );
  }
}
