import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ProjectIdText extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProjectIdState();
  }
}

class _ProjectIdState extends State<ProjectIdText> {
  String projectId = "";

  @override
  void initState() {
    super.initState();
    FirebaseApp.instance.options.then((options) {
      setState(() {
        projectId = options.projectID != null ? options.projectID : "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      projectId,
      style: TextStyle(color: Colors.black12),
    );
  }
}
