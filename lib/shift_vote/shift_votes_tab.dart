import 'package:blaulichtplaner_app/shift_vote/shift_votes_view.dart';
import 'package:blaulichtplaner_app/widgets/date_navigation.dart';
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
    return _ShiftVotesTabState();
  }
}

class _ShiftVotesTabState extends State<ShiftVotesTabWidget> {
  FilterConfig _filterConfig = FilterConfig();
  bool _selectDate = false;
  DateTime _initialDate = today();

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

  List<Widget> _createAppBarActions() {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.today),
        onPressed: () {
          setState(() {
            _selectDate = !_selectDate;
            if (!_selectDate) {
              _filterConfig.selectedDate = null;
            } else {
              _filterConfig.selectedDate = DateTime.now();
            }
          });
        },
      ),
      IconButton(
        icon: Icon(Icons.filter_list),
        onPressed: () async {
          FilterOption option = await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => _FilterMenu(
                    selectedFilterOption: _filterConfig.option,
                  ));
          if (option != null) {
            setState(() {
              _filterConfig.option = option;
            });
          }
        },
      )
    ];
  }

  Widget _createDateNavigation() {
    if (_selectDate) {
      return PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: DateNavigation(
          fromDate: _initialDate,
          initialValue: _filterConfig.selectedDate,
          onChanged: (DateTime date) {
            setState(() {
              _filterConfig.selectedDate = date;
            });
          },
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_createTitle()),
        actions: _createAppBarActions(),
        bottom: _createDateNavigation(),
      ),
      drawer: widget.drawer,
      body: ShiftVotesView(
          employeeRoles: widget.user.companyEmployeeRoles(),
          filterConfig: _filterConfig),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
