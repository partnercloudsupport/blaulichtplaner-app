import 'package:blaulichtplaner_app/widgets/date_time_picker.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:flutter/material.dart';

class EvaluationModel {
  DateTime originalFrom;
  DateTime originalTo;
  DateTime actualFrom;
  DateTime actualTo;
  int reasonOvertime = 0;
  String remarks;
  List<AssignmentTask> tasks = [];
}

class AssignmentTask {
  String type = "assignment";
  String reference;
  String remarks;
  DateTime taskTime = DateTime.now();

  AssignmentTask(this.reference);
}

typedef void SaveEvaluation(bool finish);

class EvaluationForm extends StatefulWidget {
  final EvaluationModel model;
  final SaveEvaluation onSave;

  const EvaluationForm({Key key, @required this.model, @required this.onSave})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EvaluationFormState();
  }
}

class EvaluationFormState extends State<EvaluationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  Widget _buildDialog(BuildContext context) {
    String number;
    return AlertDialog(
      title: Text("Einsatznummer"),
      content: TextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        onChanged: (value) => number = value,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Abbrechen"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text("Speichern"),
          onPressed: () {
            Navigator.pop(context, number);
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    EvaluationModel model = widget.model;
    List<Widget> assignmentRows = [];
    for (final task in model.tasks) {
      assignmentRows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(task.reference),
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  model.tasks.remove(task);
                });
              })
        ],
      ));
    }
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
                  children: <Widget>[Text("Gekommen:")],
                ),
              ),
              DateTimePickerWidget(
                fixedDates: false,
                originalDateTime: model.originalFrom,
                dateTime: model.actualFrom,
                dateTimeChanged: (dateTime) {
                  setState(() {
                    model.actualFrom = dateTime;
                  });
                },
              ),
              // FIXME add this padding directly to DateTimePickerWidget for better tapping
              Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  children: <Widget>[Text("Gegangen:")],
                ),
              ),
              DateTimePickerWidget(
                  fixedDates: false,
                  originalDateTime: model.originalTo,
                  dateTime: model.actualTo,
                  dateTimeChanged: (dateTime) {
                    setState(() {
                      model.actualTo = dateTime;
                    });
                  }),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Row(
                  children: <Widget>[Text("Grund für Überstunden")],
                ),
              ),
              Row(
                children: <Widget>[
                  DropdownButton(
                      value: model.reasonOvertime,
                      items: [
                        DropdownMenuItem(
                          child: Text("Kein Grund"),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: Text("Einsatz"),
                          value: 1,
                        ),
                        DropdownMenuItem(
                          child: Text("Nachfolger verspätet"),
                          value: 2,
                        ),
                        DropdownMenuItem(
                          child: Text("Anderer Grund"),
                          value: 99,
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          model.reasonOvertime = value;
                        });
                      }),
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Einsatznummern"),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        final number = await showDialog(
                            context: context, builder: _buildDialog);
                        if (number != null) {
                          setState(() {
                            model.tasks.add(AssignmentTask(number));
                          });
                        }
                      },
                    ),
                  ]),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: assignmentRows,
              ),
              Divider(),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(helperText: "Bemerkungen"),
                controller: TextEditingController(text: model.remarks),
                onChanged: (value) {
                  model.remarks = value;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: LoaderWidget(
                  loading: _saving,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: DateTime.now().isAfter(model.actualTo) ? () {
                          setState(() {
                            _saving = true;
                          });
                          widget.onSave(true);
                        } : null,
                        child: Text("Finalisieren"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _saving = true;
                            });
                            widget.onSave(false);
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content:
                                Text('Bitte füllen Sie alle Felder aus.')));
                          }
                        },
                        child: Text('Speichern'),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
