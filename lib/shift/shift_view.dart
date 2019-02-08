import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/widgets/date_time_picker.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftViewWidget extends StatefulWidget {
  final DocumentReference shiftRef;
  final DocumentReference employeeRef;

  const ShiftViewWidget(
      {Key key, @required this.shiftRef, @required this.employeeRef})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShiftViewState();
  }
}

class _ShiftViewModel {
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  String locationLabel = "Wollhaus, Heilbronn";
  String workAreaLabel = "Notdienst";

  String shiftplanLabel = "Februar 2019";
  String votingPhase;
  bool isVotePossible = true;
  List<AssignmentModel> assignments;
  bool isAssignedToShift = false;
}

class LabelWidget extends StatelessWidget {
  final String label;
  final Widget child;

  const LabelWidget({Key key, @required this.label, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
          child: Text(label),
        ),
        child
      ],
    );
  }
}

class _ShiftViewState extends State<ShiftViewWidget> {
  bool loading = true;

  _ShiftViewModel _shiftViewModel = _ShiftViewModel();

  @override
  void initState() {
    super.initState();
    _loadShiftInfo();
  }

  @override
  void didUpdateWidget(ShiftViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _shiftViewModel = _ShiftViewModel();
    _loadShiftInfo();
  }

  void _loadShiftInfo() async {
    setState(() {
      loading = true;
    });
    Shift shift =
        await ShiftQuery(FirestoreImpl.instance).getShift(widget.shiftRef);
    print("Shift: $shift");

    _shiftViewModel.assignments = await AssignmentQuery(FirestoreImpl.instance)
        .getAssignmentsForShift(widget.shiftRef);

    Shiftplan shiftplan = await ShiftplanQuery(FirestoreImpl.instance)
        .getShiftplan(shift.shiftplanRef);

    print("Shiftplan: $shiftplan");

    _shiftViewModel.from = shift.from;
    _shiftViewModel.to = shift.to;
    _shiftViewModel.shiftplanLabel = shiftplan.label;
    _shiftViewModel.locationLabel = shiftplan.locationLabel;
    _shiftViewModel.workAreaLabel = shift.workAreaLabel;
    if (shiftplan.voteFrom != null && shiftplan.voteTo != null) {
      String from = DateFormat.yMd("de_DE").format(shiftplan.voteFrom);
      String to = DateFormat.yMd("de_DE").format(shiftplan.voteTo);
      _shiftViewModel.votingPhase = "von $from bis $to";
      DateTime now = DateTime.now();
      _shiftViewModel.isVotePossible =
          shiftplan.voteFrom.isBefore(now) && shiftplan.voteTo.isAfter(now);
    }

    _shiftViewModel.isAssignedToShift = _shiftViewModel.assignments.firstWhere(
            (assignment) => assignment.employeeRef == widget.employeeRef,
            orElse: () => null) !=
        null;

    setState(() {
      loading = false;
    });
  }

  List<Widget> _createShiftInfo() {
    List<Widget> result = [
      ListTile(
        title: Text("Beginn"),
        subtitle: DateTimePickerWidget(
          dateTime: _shiftViewModel.from,
        ),
      ),
      ListTile(
        title: Text("Ende"),
        subtitle: DateTimePickerWidget(
          dateTime: _shiftViewModel.to,
        ),
      ),
    ];

    if (_shiftViewModel.isAssignedToShift) {
      result.add(ButtonTheme.bar(
          child: ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
            FlatButton(child: Text('Finalisieren'), onPressed: () {}),
            FlatButton(child: Text('Auswertung'), onPressed: () {})
          ])));
    }
    return result;
  }

  List<Widget> _createShiftplanInfo() {
    List<Widget> result = [
      ListTile(
        title: Text("Dienstplan"),
        subtitle: Text(
          _shiftViewModel.shiftplanLabel,
          style: TextStyle(fontSize: 18),
        ),
      ),
      ListTile(
        title: Text("Bewerbungsphase"),
        subtitle: Text(
          _shiftViewModel.votingPhase ?? "-",
          style: TextStyle(fontSize: 18),
        ),
      ),
      ListTile(
        title: Text("Standort"),
        subtitle: Text(
          _shiftViewModel.locationLabel,
          style: TextStyle(fontSize: 18),
        ),
        trailing: Icon(Icons.location_on),
      ),
      ListTile(
        title: Text("Arbeitsbereich"),
        subtitle: Text(
          _shiftViewModel.workAreaLabel,
          style: TextStyle(fontSize: 18),
        ),
      ),
    ];

//    if (_shiftViewModel.isVotePossible) {
        result.add(ButtonTheme.bar(
            child: ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
              FlatButton(child: Text('Ablehen'), onPressed: () {}),
              FlatButton(child: Text('Bewerben'), onPressed: () {})
            ])));
//    }

    return result;
  }

  List<Widget> _createAssignments() {
    List<Widget> result = [];

    if (_shiftViewModel.assignments == null ||
        _shiftViewModel.assignments.isEmpty) {
      result.add(ListTile(title: Text("Kein Personal zugeordnet")));
    } else {
      result = _shiftViewModel.assignments
          .map((assignment) => ListTile(
                title: Text(assignment.employeeLabel),
              ))
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(TitleLable(text: "Details"));
    widgets.addAll(_createShiftInfo());
    widgets.add(Divider());
    widgets.addAll(_createShiftplanInfo());
    widgets.add(Divider());
    widgets.add(TitleLable(text: "Personal"));
    widgets.addAll(_createAssignments());
    return Scaffold(
      appBar: AppBar(
        title: Text("Dienstinformationen"),
      ),
      body: LoaderWidget(
        loading: loading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
        ),
      ),
    );
  }
}

class TitleLable extends StatelessWidget {
  final String text;
  TitleLable({
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Text(
        text,
        style:
            themeData.textTheme.title.copyWith(color: themeData.primaryColor),
      ),
    );
  }
}
