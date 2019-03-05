import 'package:blaulichtplaner_app/evaluation/evaluation_editor.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class AssignmentButtonBar extends StatelessWidget {
  final LoadableWrapper<AssignmentModel> loadableAssignment;
  final Function finishCallback;

  const AssignmentButtonBar(
      {Key key,
      @required this.loadableAssignment,
      @required this.finishCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoaderWidget(
      loading: loadableAssignment.loading,
      padding: EdgeInsets.all(14.0),
      builder: (BuildContext context) {
        return ButtonTheme.bar(
          child: ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Text('Finalisieren'),
                onPressed: finishCallback,
              ),
              FlatButton(
                child: Text('Auswertung'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EvaluationEditor(
                      assignment: loadableAssignment.data,
                    );
                  }));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
