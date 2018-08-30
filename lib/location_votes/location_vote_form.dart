import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/widgets/date_time_picker.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:flutter/material.dart';

typedef void SaveLocationVote(BuildContext context, UserVote userVote);
typedef void OnChangedLocation(bool value);

class LocationTile extends StatefulWidget {
  final String locationLabel;
  final String companyLabel;
  final OnChangedLocation onChanged;
  final bool initialValue;

  const LocationTile({
    Key key,
    @required this.locationLabel,
    @required this.companyLabel,
    @required this.onChanged,
    this.initialValue = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationTileState(initialValue);
  }
}

class LocationTileState extends State<LocationTile> {
  bool _value = false;

  LocationTileState(this._value);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _value,
      title: Text(widget.locationLabel),
      subtitle: Text(widget.companyLabel),
      onChanged: (value) {
        setState(() {
          _value = value;
        });
        widget.onChanged(value);
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class LocationVoteForm extends StatefulWidget {
  final UserVote userVote;
  final SaveLocationVote saveLocationVote;
  final List<Role> employeeRoles;

  const LocationVoteForm({
    Key key,
    @required this.userVote,
    @required this.saveLocationVote,
    @required this.employeeRoles,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationVoteFormState(employeeRoles, userVote);
  }
}

class LocationVoteFormState extends State<LocationVoteForm> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  bool _saving = false;
  List<Widget> _listTiles = <Widget>[];
  final List<Role> employeeRoles;
  final UserVote userVote;

  LocationVoteFormState(this.employeeRoles, this.userVote);

  Widget _buildLocationCheckbox(int index) {
    Role employeeRole = employeeRoles[index];
    return LocationTile(
      locationLabel: employeeRole.locationLabel ?? "Unbekannter Standort",
      companyLabel: employeeRole.companyLabel ?? "Unbekannte Firma",
      onChanged: (bool value) {
        print(value);
        if (employeeRole.locationLabel != null &&
            employeeRole.locationRef != null) {
          if (value) {
            userVote.addLocation(employeeRole.reference,
                employeeRole.locationRef, employeeRole.locationLabel);
          } else {
            userVote.deleteLocation(employeeRole.reference,
                employeeRole.locationRef, employeeRole.locationLabel);
          }
        } else {
          print('locationRef and locationLabel not defined');
        }
      },
      initialValue: userVote.locations.indexWhere((UserVoteLocationItem item) =>
              item.locationRef.path == employeeRole.locationRef.path) >
          -1,
    );
  }

  _buildListTiles() {
    for (int i = 0; i < employeeRoles.length; i++) {
      _listTiles.add(_buildLocationCheckbox(i));
    }
    setState(() {
      _initialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _buildListTiles();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[Text("Von:")],
                ),
              ),
              DateTimePickerWidget(
                dateTime: userVote.from,
                dateTimeChanged: (dateTime) {
                  setState(() {
                    userVote.from = dateTime;
                  });
                },
                fixedDates: false,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[Text("Bis:")],
                ),
              ),
              DateTimePickerWidget(
                dateTime: userVote.to,
                dateTimeChanged: (dateTime) {
                  setState(() {
                    userVote.to = dateTime;
                  });
                },
                fixedDates: false,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Row(
                  children: <Widget>[Text("Mindest- und Maximaldauer")],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButton(
                        value: userVote.minHours,
                        items: [
                          DropdownMenuItem(
                            child: Text("keine"),
                            value: 0,
                          ),
                          DropdownMenuItem(
                            child: Text("min. 12 Stunden"),
                            value: 12,
                          ),
                          DropdownMenuItem(
                            child: Text("min. 24 Stunden"),
                            value: 24,
                          ),
                          DropdownMenuItem(
                            child: Text("min. 48 Stunden"),
                            value: 48,
                          )
                        ],
                        onChanged: (value) {
                          setState(() {
                            userVote.minHours = value;
                          });
                        }),
                  ),
                  Expanded(
                    child: DropdownButton(
                        value: userVote.maxHours,
                        items: [
                          DropdownMenuItem(
                            child: Text("keine"),
                            value: 0,
                          ),
                          DropdownMenuItem(
                            child: Text("max. 12 Stunden"),
                            value: 12,
                          ),
                          DropdownMenuItem(
                            child: Text("max. 24 Stunden"),
                            value: 24,
                          ),
                          DropdownMenuItem(
                            child: Text("max. 48 Stunden"),
                            value: 48,
                          )
                        ],
                        onChanged: (value) {
                          setState(() {
                            userVote.maxHours = value;
                          });
                        }),
                  ),
                ],
              ),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(helperText: "Bemerkungen"),
                controller: TextEditingController(text: userVote.remarks),
                onChanged: (value) {
                  userVote.remarks = value;
                },
              ),
              LoaderWidget(
                loading: !_initialized,
                child: ListBody(
                  children: _listTiles,
                ),
              ),
              LoaderWidget(
                loading: _saving,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _saving = true;
                          });
                          if (_formKey.currentState.validate()) {
                            print("saveBid");
                            widget.saveLocationVote(context, userVote);
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Bitte füllen Sie alle Felder aus.')));
                          }
                        },
                        child: Text('Speichern'),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
