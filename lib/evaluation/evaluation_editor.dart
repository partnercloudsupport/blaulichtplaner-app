import 'dart:async';

import 'package:blaulichtplaner_app/assignment/assignment_service.dart';
import 'package:blaulichtplaner_app/evaluation/evaluation_form.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EvaluationEditor extends StatefulWidget {
  final AssignmentModel assignment;

  const EvaluationEditor({Key key, this.assignment}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EvaluationEditorState();
  }
}

class EvaluationEditorState extends State<EvaluationEditor> {
  final model = EvaluationModel();
  bool _initialized = false;
  DocumentReference knownEvaluation;

  @override
  void initState() {
    super.initState();
    AssignmentService.initModelWithAssignment(model, widget.assignment);
    initFromPreviousEvaluation(widget.assignment.selfRef);
  }

  Future initFromPreviousEvaluation(DocumentReference assignmentRef) async {
    final query = await FirestoreImpl.instance
        .collection("evaluations")
        .where("assignmentRef", isEqualTo: assignmentRef)
        .getDocuments();
    if (query.documents.isNotEmpty) {
      final doc = query.documents.first;
      knownEvaluation = doc.reference;
      AssignmentService.initModelWithEvaluation(model, doc);
    }
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Dienstauswertung")),
        body: LoaderWidget(
          loading: !_initialized,
          child: SingleChildScrollView(
              child: EvaluationForm(
            model: model,
                onSave: (finish) async {
                  await AssignmentService.saveEvaluation(
                      knownEvaluation, widget.assignment, model, finish);
                  Navigator.pop(context);
                },
              )),
        ));
  }
}
