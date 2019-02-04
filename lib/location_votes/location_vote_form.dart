import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/widgets/date_time_picker.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:flutter/material.dart';

typedef void SaveLocationVote(BuildContext context, UserVote userVote);
typedef void OnChangedLocation(bool value);
typedef void OnChanged(
  DocumentReference employeeRef,
  DocumentReference locationRef,
  String locationLabel,
);

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

class ShiftDuration {
  int min;
  int max;
  ShiftDuration({this.min, this.max});
}

class ShiftDurationFormField extends FormField<ShiftDuration> {
  ShiftDurationFormField({
    Key key,
    ShiftDuration initialValue,
    ValueChanged<ShiftDuration> onChanged,
    FormFieldSetter<ShiftDuration> onSaved,
  }) : super(
          key: key,
          initialValue: initialValue ?? ShiftDuration(min: 0, max: 0),
          onSaved: onSaved,
          validator: (ShiftDuration val) {
            if (val.min > val.max) {
              return 'Maximal- muss über Minimaldauer liegen';
            }
          },
          autovalidate: false,
          builder: (FormFieldState<ShiftDuration> field) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: <Widget>[
                      Text("Mindest- und Maximaldauer"),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          DropdownButton(
                            value: initialValue.min ?? 0,
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
                            onChanged: (int val) {
                              ShiftDuration duration = field.value;
                              duration.min = val;
                              onChanged(duration);
                              field.didChange(duration);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          DropdownButton(
                            value: initialValue.max ?? 0,
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
                            onChanged: (int val) {
                              ShiftDuration duration = field.value;
                              duration.max = val;
                              onChanged(duration);
                              field.didChange(duration);
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      field.hasError ? field.errorText : '',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ],
            );
          },
        );
  @override
  ShiftDurationFormFieldState createState() => ShiftDurationFormFieldState();
}

class ShiftDurationFormFieldState extends FormFieldState<ShiftDuration> {
  @override
  get widget => super.widget;
}

class LocationList extends StatefulWidget {
  final String errorText;
  final List<UserRole> employeeRoles;
  final OnChanged addLocation;
  final OnChanged deleteLocation;
  const LocationList({
    Key key,
    @required this.errorText,
    @required this.employeeRoles,
    @required this.addLocation,
    @required this.deleteLocation,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationListState();
  }
}

class LocationListState extends State<LocationList> {
  List<Widget> _listTiles = <Widget>[];
  bool _initialized = false;
  UserVote userVote = UserVote();

  Widget _buildLocationCheckbox(int index) {
    UserRole employeeRole = widget.employeeRoles[index];
    return LocationTile(
      locationLabel:  "Unbekannter Standort",
      companyLabel:  "Unbekannte Firma",
    );
  }

  _buildListTiles() {
    for (int i = 0; i < widget.employeeRoles.length; i++) {
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
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Row(
            children: <Widget>[
              Text('Standorte'),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Text(
              widget.errorText,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        LoaderWidget(
          loading: !_initialized,
          child: ListBody(
            children: _listTiles,
          ),
        ),
      ],
    );
  }
}

class LocationListFormField extends FormField<int> {
  LocationListFormField({
    Key key,
    int value,
    List<UserRole> employeeRoles,
    bool enabled,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    OnChanged addLocation,
    OnChanged deleteLocation,
  }) : super(
          key: key,
          initialValue: value ?? 0,
          onSaved: (int value) {
            print(value);
          },
          validator: (int val) {
            if (val < 1) {
              return "Mindestens einen Standort auswählen.";
            }
          },
          autovalidate: false,
          builder: (FormFieldState<int> field) {
            return LocationList(
              errorText: field.hasError ? field.errorText : '',
              addLocation: (DocumentReference reference,
                  DocumentReference locationRef, String locationLabel) {
                field.didChange(field.value + 1);
                addLocation(reference, locationRef, locationLabel);
              },
              deleteLocation: (DocumentReference reference,
                  DocumentReference locationRef, String locationLabel) {
                field.didChange(field.value - 1);
                deleteLocation(reference, locationRef, locationLabel);
              },
              employeeRoles: employeeRoles,
            );
          },
        );
}

class LocationListFormFieldState extends FormFieldState<int> {
  @override
  get widget => super.widget;
  @override
  void didUpdateWidget(LocationListFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(value);
  }
}

class LocationVoteForm extends StatefulWidget {
  final UserVote userVote;
  final SaveLocationVote saveLocationVote;
  final List<UserRole> employeeRoles;

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

class FromTo {
  DateTime from;
  DateTime to;
  FromTo({this.from, this.to});
}

class DateFormField extends FormField<FromTo> {
  DateFormField({
    Key key,
    FromTo initialValue,
    ValueChanged<FromTo> onChanged,
    FormFieldSetter<FromTo> onSaved,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: (FromTo val) {
            if (val.from.isAfter(val.to)) {
              return 'Endzeit muss nach Startzeit liegen.';
            }
          },
          builder: (FormFieldState<FromTo> field) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: <Widget>[Text("Von:")],
                  ),
                ),
                DateTimePickerWidget(
                  dateTime: initialValue.from,
                  dateTimeChanged: (DateTime val) {
                    FromTo fromTo = field.value;
                    fromTo.from = val;
                    onChanged(fromTo);
                    field.didChange(fromTo);
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
                  dateTime: initialValue.to,
                  dateTimeChanged: (DateTime val) {
                    FromTo fromTo = field.value;
                    fromTo.to = val;
                    onChanged(fromTo);
                    field.didChange(fromTo);
                  },
                  fixedDates: false,
                ),
                Row(
                  children: <Widget>[
                    Text(field.hasError ? field.errorText : '',
                        style: TextStyle(
                          color: Colors.red,
                        )),
                  ],
                ),
              ],
            );
          },
        );
}

class DateFormFieldState extends FormFieldState<FromTo> {
  @override
  get widget => super.widget;
}

class LocationVoteFormState extends State<LocationVoteForm> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  final List<UserRole> employeeRoles;
  final UserVote userVote;

  LocationVoteFormState(this.employeeRoles, this.userVote);

  @override
  void initState() {
    super.initState();
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
              DateFormField(
                initialValue: FromTo(
                  from: userVote.from,
                  to: userVote.to,
                ),
                onChanged: (FromTo val) {
                  setState(() {
                    userVote.from = val.from;
                    userVote.to = val.to;
                  });
                },
                onSaved: (FromTo val) {
                  setState(() {
                    userVote.from = val.from;
                    userVote.to = val.to;
                  });
                },
              ),
              ShiftDurationFormField(
                initialValue: ShiftDuration(
                  min: userVote.minHours,
                  max: userVote.maxHours,
                ),
                onChanged: (ShiftDuration val) {
                  setState(() {
                    userVote.minHours = val.min;
                    userVote.maxHours = val.max;
                  });
                },
                onSaved: (ShiftDuration val) {
                  setState(() {
                    userVote.minHours = val.min;
                    userVote.maxHours = val.max;
                  });
                },
              ),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(helperText: "Bemerkungen"),
                controller: TextEditingController(text: userVote.remarks),
                onChanged: (value) {
                  userVote.remarks = value;
                },
              ),
              LocationListFormField(
                employeeRoles: employeeRoles,
                value: userVote.locations.length,
                addLocation: userVote.addLocation,
                deleteLocation: userVote.deleteLocation,
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
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _saving = true;
                            });
                            if (userVote.to
                                .subtract(Duration(hours: 1))
                                .isBefore(userVote.from)) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Die Dauer muss mindestens eine Stunde betragen.')));
                            } else {
                              widget.saveLocationVote(context, userVote);
                            }
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
