import 'dart:async';

import 'package:blaulichtplaner_app/auth/authentication.dart';
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
  EvaluationModel model;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initFromPreviousEvaluation();
  }

  Future _initFromPreviousEvaluation() async {
    EvaluationQuery evaluationQuery = EvaluationQuery(FirestoreImpl.instance);
    model = await evaluationQuery.getEvaluationForAssignment(widget.assignment);
    setState(() {
      _initialized = true;
    });
  }

  void _saveEvaluation(bool finish) async {
    await EvaluationSave(FirestoreImpl.instance,
            ActionContext(UserManager.instance.user, null, null))
        .performAction(EvaluationAction(model, finish));
    Navigator.pop(context);
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
            onSave: _saveEvaluation,
          ),
        ),
      ),
    );
  }
}
