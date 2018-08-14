import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:blaulichtplaner_app/widgets/date_time_picker.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:flutter/material.dart';

typedef void SaveLocationVote(BuildContext context, LocationVote locationVote);

class LocationVoteForm extends StatefulWidget {
  final LocationVote locationVote;
  final SaveLocationVote saveLocationVote;
  final List<Role> employeeRoles;

  const LocationVoteForm({
    Key key,
    @required this.locationVote,
    @required this.saveLocationVote,
    @required this.employeeRoles,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationVoteFormState();
  }
}

class LocationVoteFormState extends State<LocationVoteForm> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  List<Widget> _listTiles = <Widget>[];
  Widget _buildLocationCheckbox(int index) {
    return CheckboxListTile(
      value: false,
      title: Text(widget.employeeRoles[index].locationLabel ?? "hi"),
      subtitle: Text(widget.employeeRoles[index].companyLabel ?? "hi"),
      onChanged: (val) {},
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  _buildListTiles() {
    for (int i = 0; i < widget.employeeRoles.length; i++) {
      _listTiles.add(_buildLocationCheckbox(i));
    }
    setState(() {
      _loading = false;
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
                dateTime: widget.locationVote.from,
                dateTimeChanged: (dateTime) {
                  setState(() {
                    widget.locationVote.from = dateTime;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  children: <Widget>[Text("Bis:")],
                ),
              ),
              DateTimePickerWidget(
                  dateTime: widget.locationVote.to,
                  dateTimeChanged: (dateTime) {
                    setState(() {
                      widget.locationVote.to = dateTime;
                    });
                  }),
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
                        value: widget.locationVote.minHours,
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
                            widget.locationVote.minHours = value;
                          });
                        }),
                  ),
                  Expanded(
                    child: DropdownButton(
                        value: widget.locationVote.maxHours,
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
                            widget.locationVote.maxHours = value;
                          });
                        }),
                  ),
                ],
              ),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(helperText: "Bemerkungen"),
                controller:
                    TextEditingController(text: widget.locationVote.remarks),
                onChanged: (value) {
                  widget.locationVote.remarks = value;
                },
              ),
              LoaderWidget(
                loading: _loading,
                child: ListBody(
                  children: _listTiles,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          print("saveBid");
                          widget.saveLocationVote(context, widget.locationVote);
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Bitte füllen Sie alle Felder aus.')));
                        }
                      },
                      child: Text('Bewerben'),
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}
