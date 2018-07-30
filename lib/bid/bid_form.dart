import 'package:blaulichtplaner_app/widgets/date_time_picker.dart';
import 'package:flutter/material.dart';

class BidModel {
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();
  int minHours = 0;
  int maxHours = 0;
  String remarks;
}

typedef void SaveBid(BidModel bidModel);

class BidForm extends StatefulWidget {
  final BidModel bidModel;
  final SaveBid saveBid;

  const BidForm({Key key, @required this.bidModel, @required this.saveBid})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BidFormState(bidModel);
  }
}

class BidFormState extends State<BidForm> {
  final _formKey = GlobalKey<FormState>();
  final BidModel bidModel;

  BidFormState(this.bidModel);

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
                dateTime: bidModel.from,
                dateTimeChanged: (dateTime) {
                  setState(() {
                    bidModel.from = dateTime;
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
                  dateTime: bidModel.to,
                  dateTimeChanged: (dateTime) {
                    setState(() {
                      bidModel.to = dateTime;
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
                        value: bidModel.minHours,
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
                            bidModel.minHours = value;
                          });
                        }),
                  ),
                  Expanded(
                    child: DropdownButton(
                        value: bidModel.maxHours,
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
                            bidModel.maxHours = value;
                          });
                        }),
                  ),
                ],
              ),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(helperText: "Bemerkungen"),
                controller: TextEditingController(text: bidModel.remarks),
                onChanged: (value) {
                  bidModel.remarks = value;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          widget.saveBid(bidModel);
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
