import 'dart:async';

import 'package:blaulichtplaner_app/evaluation/evaluation_form.dart';
import 'package:blaulichtplaner_app/shift_view.dart';
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
  final EvaluationModel model = EvaluationModel();
  bool _initialized = false;
  DocumentReference knownEvaluation;

  @override
  void initState() {
    super.initState();
    Assignment assignment = widget.assignment;
    model.originalFrom = assignment.from;
    model.originalTo = assignment.to;
    model.actualFrom = assignment.from;
    model.actualTo = assignment.to;
    model.reasonOvertime = 0;
    initFromPreviousEvaluation(assignment.selfRef);
  }

  Future initFromPreviousEvaluation(DocumentReference assignmentRef) async {
    final query = await Firestore.instance
        .collection("evaluations")
        .where("assignmentRef", isEqualTo: assignmentRef)
        .getDocuments();
    if (query.documents.isNotEmpty) {
      final doc = query.documents.first;
      knownEvaluation = doc.reference;
      model.actualFrom = doc.data["actualFrom"];
      model.actualTo = doc.data["actualTo"];
      model.reasonOvertime = doc.data["reasonOvertime"];
      model.remarks = doc.data["remarks"];
      model.assignmentNumbers = List.from(doc.data["assignmentNumbers"]);
    }
    setState(() {
      _initialized = true;
    });
  }

  Future _saveEvaluation(bool finish) async {
    Map<String, dynamic> data = {};
    data["finished"] = finish;
    data["actualFrom"] = model.actualFrom;
    data["actualTo"] = model.actualTo;
    data["reasonOvertime"] = model.reasonOvertime;
    data["remarks"] = model.remarks;
    data["assignmentRef"] = widget.assignment.selfRef;
    data["shiftplanRef"] = widget.assignment.shiftplanRef;
    data["assignmentNumbers"] = model.assignmentNumbers;
    if (knownEvaluation == null) {
      knownEvaluation = await Firestore.instance
          .collection("evaluations")
          .add({"created": DateTime.now()});
    }

    DocumentReference assignmentRef = widget.assignment.selfRef;

    return Firestore.instance.runTransaction((transaction) async {
      await transaction.update(knownEvaluation, data);
      if (finish) {
        await transaction.update(assignmentRef, {"evaluated": true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return Scaffold(
          appBar: AppBar(title: Text("Dienstauswertung")),
          body: SingleChildScrollView(
              child: EvaluationForm(
            model: model,
                onSave: (finish) async {
                  await _saveEvaluation(finish);
                  Navigator.pop(context);
                },
          )));
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("Dienstauswertung")),
        body: new Container(
            color: Colors.white,
            child: new Center(
              child: new Column(
                children: <Widget>[CircularProgressIndicator()],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            )),
      );
    }
  }
}
