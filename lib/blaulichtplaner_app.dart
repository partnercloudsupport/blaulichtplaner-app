import 'package:blaulichtplaner_app/assignment/assignment_view.dart';
import 'package:blaulichtplaner_app/authentication.dart';
import 'package:blaulichtplaner_app/invitation/invitation_view.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote_editor.dart';
import 'package:blaulichtplaner_app/location_votes/location_votes_view.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_view.dart';
import 'package:blaulichtplaner_app/shiftplan/shiftplan_overview.dart';
import 'package:blaulichtplaner_app/widgets/date_navigation.dart';
import 'package:blaulichtplaner_app/widgets/drawer.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class BlaulichtplanerApp extends StatefulWidget {
  final Function logoutCallback;

  const BlaulichtplanerApp({Key key, this.logoutCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlaulichtPlanerAppState();
  }
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

class BlaulichtPlanerAppState extends State<BlaulichtplanerApp> {
  int selectedTab = 0;
  bool upcomingShifts = true;
  bool upcomingPlans = true;
  String currentTitle = "Blaulichtplaner";
  FilterOptions _selectedFilterOption = FilterOptions.allShifts;
  bool _selectDate = false;
  DateTime _initialDate;
  DateTime _selectedDate;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initialDate = DateTime.now();
    _selectedDate = DateTime.now();
  }

  Widget _createBody(BlpUser user) {
    switch (selectedTab) {
      case 0:
        return AssignmentView(
            employeeRoles: user.employeeRoles(),
            upcomingShifts: upcomingShifts);
      case 1:
        return ShiftplanOverview(
          employeeRoles: user.employeeRoles(),
        );
      case 2:
        return ShiftVotesView(
          employeeRoles: user.companyEmployeeRoles(),
          filter: _selectedFilterOption,
          selectedDate: _selectDate ? _selectedDate : null,
        );
      default:
        return Text("unkown tab id");
    }
  }

  List<Widget> _createAppBarActions(BlpUser user) {
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
            onPressed: null /* user.hasEmployeeRoles()
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return LocationVoteEditor(
                            employeeRoles: user.employeeRoles(),
                            userVote: UserVote(),
                          );
                        },
                      ),
                    );
                  }
                : null,*/
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
          fromDate: _initialDate,
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

  @override
  Widget build(BuildContext context) {
    BlpUser user = UserWidget.of(context).user;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_createTitle()),
        actions: _createAppBarActions(user),
        bottom: _createDateNavigation(),
      ),
      drawer: DrawerWidget(
        user: user,
        invitationCallback: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => InvitationScreen(

                    onSaved: () {
                      //user.updateUserData(user);
                    },
                  ),
            ),
          );
        },
        logoutCallback: widget.logoutCallback,
        employeeRoles: user.employeeRoles(),
      ),
      body: _createBody(user),
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
}
