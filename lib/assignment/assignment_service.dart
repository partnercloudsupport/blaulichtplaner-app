import 'dart:async';

import 'package:blaulichtplaner_app/evaluation/evaluation_form.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';


class AssignmentModel {
  DocumentReference selfRef;
  DateTime from;
  DateTime to;
  String workAreaLabel;
  String locationLabel;
  DocumentReference shiftRef;
  DocumentReference shiftplanRef;
  DocumentReference employeeRef;

  AssignmentModel.fromSnapshot(DocumentSnapshot snapshot) {
    selfRef = snapshot.reference;
    from = snapshot.data["from"];
    to = snapshot.data["to"];
    workAreaLabel = snapshot.data["workAreaLabel"];
    locationLabel = snapshot.data["locationLabel"];
    shiftRef = snapshot.data["shiftRef"];
    shiftplanRef = snapshot.data["shiftplanRef"];
    employeeRef = snapshot.data["employeeRef"];
  }

  Duration toFromDifference() {
    return to.difference(from);
  }

  bool fromIsBefore(DateTime dateTime) {
    return from != null && from.isBefore(dateTime);
  }
}

class AssignmentService {
  static void initModelWithEvaluation(
      EvaluationModel model, DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data;
    model.actualFrom = data["actualFrom"];
    model.actualTo = data["actualTo"];
    model.reasonOvertime = data["reasonOvertime"];
    model.remarks = data["remarks"];
    List list = data["tasks"];
    model.tasks = list.map(_mapToTask).toList();
  }

  static void initModelWithAssignment(
      EvaluationModel model, AssignmentModel assignment) {
    model.originalFrom = assignment.from;
    model.originalTo = assignment.to;
    model.actualFrom = assignment.from;
    model.actualTo = assignment.to;
    model.reasonOvertime = 0;
  }

  static Map<String, dynamic> _taskToMap(AssignmentTask task) {
    Map<String, dynamic> data = {};
    data["type"] = task.type;
    data["reference"] = task.reference;
    data["remarks"] = task.remarks;
    data["taskTime"] = task.taskTime;
    return data;
  }

  static AssignmentTask _mapToTask(data) {
    AssignmentTask task = AssignmentTask(data["reference"]);
    task.remarks = data["remarks"];
    task.type = data["type"];
    task.taskTime = data["taskTime"];
    return task;
  }

  static Map<String, dynamic> _createData(
      EvaluationModel model, bool finish, AssignmentModel assignment) {
    Map<String, dynamic> data = {};
    data["finished"] = finish;
    data["actualFrom"] = model.actualFrom;
    data["actualTo"] = model.actualTo;
    data["reasonOvertime"] = model.reasonOvertime;
    data["remarks"] = model.remarks;
    data["assignmentRef"] = assignment.selfRef;
    data["shiftplanRef"] = assignment.shiftplanRef;
    data["tasks"] = model.tasks.map(_taskToMap).toList();
    data["employeeRef"] = assignment.employeeRef;
    data["shiftRef"] = assignment.shiftRef;
    return data;
  }

  static Future finishAssignment(AssignmentModel assignment) async {
    final query = await FirestoreImpl.instance
        .collection("evaluations")
        .where("assignmentRef", isEqualTo: assignment.selfRef)
        .getDocuments();
    DocumentReference knownEvaluation;
    EvaluationModel model = EvaluationModel();
    initModelWithAssignment(model, assignment);
    if (query.documents.isNotEmpty) {
      final doc = query.documents.first;
      knownEvaluation = doc.reference;
      initModelWithEvaluation(model, doc);
    }
    return saveEvaluation(knownEvaluation, assignment, model, true);
  }

  static Future saveEvaluation(DocumentReference knownEvaluation,
      AssignmentModel assignment, EvaluationModel model, bool finish) async {
    final data = _createData(model, finish, assignment);
    if (knownEvaluation == null) {
      knownEvaluation = await FirestoreImpl.instance
          .collection("evaluations")
          .add({"created": DateTime.now()});
    }

    return FirestoreImpl.instance.runTransaction((transaction) async {
      print(knownEvaluation.path);

      await transaction.update(knownEvaluation, data);
      if (finish) {
        await transaction.update(assignment.selfRef, {"evaluated": true});
      }
    });
  }
}
