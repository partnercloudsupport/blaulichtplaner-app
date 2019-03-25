import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/location/location_view.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_votes_view.dart';
import 'package:blaulichtplaner_app/widgets/connection_widget.dart';
import 'package:blaulichtplaner_app/widgets/date_navigation.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class _FilterMenu extends StatelessWidget {
  final FilterOption selectedFilterOption;

  _FilterMenu({Key key, @required this.selectedFilterOption}) : super(key: key);

  void _onChanged(BuildContext context, FilterOption selectedOption) {
    Navigator.of(context).pop(selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile(
            groupValue: selectedFilterOption,
            onChanged: (selectedOption) {
              _onChanged(context, selectedOption);
            },
            value: FilterOption.withoutVote,
            title: Row(
              children: <Widget>[
                Text('Unbesetzte Dienste'),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.help,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          RadioListTile(
            groupValue: selectedFilterOption,
            onChanged: (selectedOption) {
              _onChanged(context, selectedOption);
            },
            value: FilterOption.accepted,
            title: Row(
              children: <Widget>[
                Text('Dienste mit Bewerbung'),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          RadioListTile(
            groupValue: selectedFilterOption,
            onChanged: (selectedOption) {
              _onChanged(context, selectedOption);
            },
            value: FilterOption.rejected,
            title: Row(
              children: <Widget>[
                Text('Abgelehnte Dienste'),
                Padding(
                  padding: EdgeInsets.only(left: 8),
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
      padding: EdgeInsets.all(16),
    );
  }
}

class ShiftVotesTabWidget extends StatefulWidget {
  final BottomNavigationBar bottomNavigationBar;
  final Widget drawer;
  final BlpUser user;

  const ShiftVotesTabWidget(
      {Key key,
      @required this.bottomNavigationBar,
      @required this.drawer,
      @required this.user})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShiftVotesTabState(user.companyEmployeeRoles());
  }
}

class _ShiftVotesTabState extends State<ShiftVotesTabWidget> {
  final List<CompanyEmployeeRole> companyRoles;
  List<ShiftVote> _shiftVotes = [];
  FilterConfig _filterConfig = FilterConfig();
  DateTime _initialDate = today();
  bool _initialized = false;
  ShiftVoteHolder _shiftVoteHolder;

  _ShiftVotesTabState(this.companyRoles);

  @override
  void initState() {
    super.initState();
    _initDataListeners();
  }

  void _initDataListeners() async {
    _shiftVoteHolder = ShiftVoteHolder(
        companyRoles, FirestoreImpl.instance, _updateShiftVotes);
    // load favorites first
    await _loadFavorites();
    await _shiftVoteHolder.initListeners();
    setState(() {
      _initialized = true;
    });
  }

  void _updateShiftVotes() {
    List<ShiftVote> filteredShiftVotes = _filterShiftVotes();
    setState(() {
      _shiftVotes = filteredShiftVotes;
    });
  }

  List<ShiftVote> _filterShiftVotes() {
    List<ShiftVote> unfilteredShiftVotes = _shiftVoteHolder.shiftVotes;
    List<ShiftVote> filteredShifts =
        unfilteredShiftVotes.where(_filterConfig.filter).toList();
    return filteredShifts;
  }

  @override
  void didUpdateWidget(ShiftVotesTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _initialized = false;
    });
    _shiftVoteHolder?.cancelSubscriptions();
    _shiftVoteHolder?.clear();
    _initDataListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _shiftVoteHolder?.cancelSubscriptions();
  }

  Future<void> _loadFavorites() async {
    DocumentReference favoritesRef = widget.user.userRef
        .collection("settings")
        .document("locationFavorites");

    DocumentSnapshot snapshot = await favoritesRef.document;
    if (snapshot.exists) {
      List<DocumentReference> favorites =
          List.castFrom(snapshot.data["favorites"]);
      if (favorites != null) {
        _filterConfig.favoriteLocations = Set.from(favorites);
      } else {
        _filterConfig.favoriteLocations = null;
      }
    }
  }

  String _createTitle() {
    switch (_filterConfig.option) {
      case FilterOption.withoutVote:
        return "Unbesetzte Dienste";
      case FilterOption.accepted:
        return "Beworbene Diente";
      case FilterOption.rejected:
      default:
        return "Abgelehnte Dienste";
    }
  }

  _fallbackText() {
    String suffix = _filterConfig.hasFilterBesidesOption
        ? ", die dem Filter entsprechen"
        : "";
    switch (_filterConfig.option) {
      case FilterOption.rejected:
        return 'Keine abgelehnten Dienste' + suffix;
      case FilterOption.accepted:
        return 'Keine Dienste mit Bewerbung' + suffix;
      case FilterOption.withoutVote:
        return 'Keine unbesetzten Dienste' + suffix;
    }
  }

  _filterVotes() async {
    FilterOption option = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => _FilterMenu(
              selectedFilterOption: _filterConfig.option,
            ));
    if (option != null) {
      _filterConfig.option = option;
      _updateShiftVotes();
    }
  }

  _filterLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationView(
              companyRefs: companyRoles.map((role) => role.reference).toList(),
              favoritesForSelection: true,
            ),
      ),
    );
  }

  List<Widget> _createAppBarActions() {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.today),
        onPressed: () {
          if (_filterConfig.selectedDate != null) {
            _filterConfig.selectedDate = null;
          } else {
            _filterConfig.selectedDate = DateTime.now();
          }
          _updateShiftVotes();
        },
      ),
      PopupMenuButton(
          onSelected: (String menu) {
            switch (menu) {
              case "location_filter":
                _filterLocation();
                break;

              case "type_filter":
                _filterVotes();
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: "location_filter",
                  child: Text('Standortfilter'),
                ),
                const PopupMenuItem<String>(
                  value: "type_filter",
                  child: Text('Filtern'),
                ),
              ])
    ];
  }

  Widget _createBottom() {
    if (_filterConfig.hasFilterBesidesOption) {
      List<Widget> elements = [];
      if (_filterConfig.selectedDate != null) {
        elements.add(DateNavigation(
          fromDate: _initialDate,
          initialValue: _filterConfig.selectedDate,
          onChanged: (DateTime date) {
            setState(() {
              _filterConfig.selectedDate = date;
            });
          },
        ));
      }
      if (_filterConfig.hasFavoriteLocationsFilter) {
        elements.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Standortfilter aktiv.",
            style: TextStyle(color: Colors.white),
          ),
        ));
      }
      return PreferredSize(
          preferredSize:
              elements.length == 1 ? Size.fromHeight(48) : Size.fromHeight(96),
          child: Column(
            children: elements,
          ));
    } else {
      return null;
    }
  }

  Widget _body() {
    if (companyRoles != null && companyRoles.isNotEmpty) {
      return LoaderBodyWidget(
        loading: !_initialized,
        child: ShiftVotesView(
          shiftVotes: _shiftVotes,
        ),
        fallbackText: _fallbackText(),
        empty: _shiftVotes.isEmpty,
      );
    } else {
      return NoEmployee();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_createTitle()),
        actions: _createAppBarActions(),
        bottom: _createBottom(),
      ),
      drawer: widget.drawer,
      body: ConnectionWidget(child: _body()),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
