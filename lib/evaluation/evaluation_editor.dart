import 'dart:async';

import 'package:blaulichtplaner_app/assignment/assignment_service.dart';
import 'package:blaulichtplaner_app/evaluation/evaluation_form.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EvaluationEditor extends StatefulWidget {
  final Assignment assignment;

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
  final assignmentService = AssignmentService();

  @override
  void initState() {
    super.initState();
    assignmentService.initModelWithAssignment(model, widget.assignment);
    initFromPreviousEvaluation(widget.assignment.selfRef);
  }

  Future initFromPreviousEvaluation(DocumentReference assignmentRef) async {
    final query = await Firestore.instance
        .collection("evaluations")
        .where("assignmentRef", isEqualTo: assignmentRef)
        .getDocuments();
    if (query.documents.isNotEmpty) {
      final doc = query.documents.first;
      knownEvaluation = doc.reference;
      assignmentService.initModelWithEvaluation(model, doc.data);
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
                  await assignmentService.saveEvaluation(
                      knownEvaluation, widget.assignment, model, finish);
                  Navigator.pop(context);
                },
              )),
        ));
  }
}
