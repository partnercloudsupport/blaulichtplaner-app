import 'package:blaulichtplaner_app/widgets/date_time_picker.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

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

class OvertimeWidget extends StatelessWidget {
  final int startValue;
  final Function changeCallback;
  final bool overtime;
  OvertimeWidget(
      {Key key,
      @required this.changeCallback,
      @required this.startValue,
      @required this.overtime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (overtime) {
      return Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Row(
            children: <Widget>[Text("Grund für Überstunden")],
          ),
        ),
        Row(
          children: <Widget>[
            DropdownButton(
                value: startValue,
                items: [
                  DropdownMenuItem(
                    child: Text("Bitte auswählen"),
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
                onChanged: changeCallback),
          ],
        ),
      ]);
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.check,
                color: Colors.green,
              ),
            ),
            Text("Keine Überstunden"),
          ],
        ),
      );
    }
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
          child: Text("Hinzufügen"),
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
    List<Widget> formItems = <Widget>[
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
      OvertimeWidget(
        changeCallback: (value) {
          setState(() {
            model.reasonOvertime = value;
          });
        },
        startValue: model.reasonOvertime,
        overtime: model.isOvertime(),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text("Einsatznummern"),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            final number =
                await showDialog(context: context, builder: _buildDialog);
            if (number != null) {
              addTask(model, number);
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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: LoaderWidget(
          loading: _saving,
          child: ButtonTheme.bar(
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  textColor: Colors.red,
                  onPressed: DateTime.now().isAfter(model.actualTo)
                      ? () {
                          setState(() {
                            _saving = true;
                          });
                          widget.onSave(true);
                        }
                      : null,
                  child: Text("Final auswerten"),
                ),
                FlatButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        _saving = true;
                      });
                      widget.onSave(false);
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Bitte füllen Sie alle Felder aus.')));
                    }
                  },
                  child: Text('Speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
      Text(
        "Sie können die Auswertung jederzeit speichern und später final auswerten. Nach der finalen Auswertung sind keine Änderungen mehr möglich.",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      )
    ];
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: formItems),
      ),
    );
  }

  void addTask(EvaluationModel model, String number) {
    AssignmentTask task = model.tasks.firstWhere(
        (knownTasks) => knownTasks.reference == number,
        orElse: () => null);
    if (task == null) {
      setState(() {
        model.tasks.add(AssignmentTask(number));
      });
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Einsatznummer existiert bereits"),
      ));
    }
  }
}
