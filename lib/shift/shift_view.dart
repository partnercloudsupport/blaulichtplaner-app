import 'package:blaulichtplaner_app/assignment/assignment_botton_bar.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_vote_button_bar.dart';
import 'package:blaulichtplaner_app/widgets/date_time_picker.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ShiftViewWidget extends StatefulWidget {
  final DocumentReference shiftRef;
  final DocumentReference currentEmployeeRef;

  const ShiftViewWidget(
      {Key key, @required this.shiftRef, @required this.currentEmployeeRef})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShiftViewState();
  }
}

class _ShiftViewModel {
  DateTime from;
  DateTime to;

  String locationLabel;
  String locationAddress;
  String locationInfoUrl;
  String workAreaLabel;

  String shiftplanLabel;
  String votingPhase;
  bool isVotingPhaseActive;
  bool isVotePossible;
  List<AssignmentModel> assignments;
  LoadableWrapper<AssignmentModel> currentEmployeeAssignment;
  AssignmentStatus currentEmployeeAssignmentStatus;

  ShiftVote shiftVote;

  bool get isAssignedToShift => currentEmployeeAssignment != null;
  bool get isPastShift => DateTime.now().isAfter(to);
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

    _shiftViewModel.assignments = await AssignmentQuery(FirestoreImpl.instance)
        .getAssignmentsForShift(widget.shiftRef);

    Shiftplan shiftplan = await ShiftplanQuery(FirestoreImpl.instance)
        .getShiftplan(shift.shiftplanRef);

    CompanyLocation companyLocation =
        await LocationQuery(FirestoreImpl.instance)
            .getLocation(shiftplan.locationRef);

    _shiftViewModel.from = shift.from;
    _shiftViewModel.to = shift.to;
    _shiftViewModel.shiftplanLabel = shiftplan.label;
    _shiftViewModel.locationLabel = companyLocation.locationLabel;
    _shiftViewModel.locationAddress =
        companyLocation.hasAddress() ? companyLocation.createAddress() : null;
    _shiftViewModel.locationInfoUrl = companyLocation.infoUrl;
    _shiftViewModel.workAreaLabel = shift.workAreaLabel;
    if (shiftplan.voteFrom != null && shiftplan.voteTo != null) {
      String from = DateFormat.yMd("de_DE").format(shiftplan.voteFrom);
      String to = DateFormat.yMd("de_DE").format(shiftplan.voteTo);
      _shiftViewModel.votingPhase = "von $from bis $to";
      DateTime now = DateTime.now();
      _shiftViewModel.isVotingPhaseActive =
          shiftplan.voteFrom.isBefore(now) && shiftplan.voteTo.isAfter(now);
    }

    _shiftViewModel.isVotePossible = _shiftViewModel.isVotingPhaseActive;
    // always allow voting if shift is unmanned
    if (!shift.manned) {
      _shiftViewModel.isVotePossible = true;
    }
    if (_shiftViewModel.isPastShift) {
      _shiftViewModel.isVotePossible = false;
    }

    AssignmentModel assignmentModel = _shiftViewModel.assignments.firstWhere(
        (assignment) => assignment.employeeRef == widget.currentEmployeeRef,
        orElse: () => null);

    _shiftViewModel.currentEmployeeAssignment =
        assignmentModel != null ? LoadableWrapper(assignmentModel) : null;
    _shiftViewModel.currentEmployeeAssignmentStatus =
        AssignmentStatus(assignmentModel);

    Vote vote = await VoteQuery(FirestoreImpl.instance)
        .getVote(widget.shiftRef, widget.currentEmployeeRef);

    _shiftViewModel.shiftVote = ShiftVote(widget.currentEmployeeRef,
        shift: shift, assignment: assignmentModel, vote: vote);

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
      result.add(AssignmentButtonBar(
        loadableAssignment: _shiftViewModel.currentEmployeeAssignment,
        finishCallback:
            _shiftViewModel.currentEmployeeAssignmentStatus.canBeFinished
                ? () async {
                    await finishEvaluation(
                        _shiftViewModel.currentEmployeeAssignment.data,
                        FirestoreImpl.instance);
                    _loadShiftInfo();
                  }
                : null,
      ));
    }
    return result;
  }

  List<Widget> _createShiftplanInfo() {
    List<Widget> result = [];
    result.add(ListTile(
      title: Text("Dienstplan"),
      subtitle: Text(
        _shiftViewModel.shiftplanLabel,
        style: TextStyle(fontSize: 18),
      ),
    ));
    result.add(ListTile(
      title: Text("Bewerbungsphase"),
      subtitle: Text(
        _shiftViewModel.votingPhase ?? "-",
        style: TextStyle(fontSize: 18),
      ),
    ));
    result.add(ListTile(
        title: Text("Standort"),
        subtitle: Text(
          _shiftViewModel.locationLabel,
          style: TextStyle(fontSize: 18),
        )));
    if (_shiftViewModel.locationAddress != null) {
      result.add(ListTile(
        title: Text("Adresse"),
        subtitle: Text(
          _shiftViewModel.locationAddress,
          style: TextStyle(fontSize: 18),
        ),
        trailing: Icon(Icons.location_on),
        onTap: () async {
          String url = Uri.https("www.google.com", "/maps/search/", {
            "api": "1",
            "query": _shiftViewModel.locationAddress
          }).toString();
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Can not launch $url';
          }
        },
      ));
    }
    if (_shiftViewModel.locationInfoUrl != null) {
      result.add(ListTile(
        title: Text("Standortinformationen"),
        subtitle: Text(
          _shiftViewModel.locationInfoUrl,
          style: TextStyle(fontSize: 18),
        ),
        trailing: Icon(Icons.link),
        onTap: () async {
          String url = _shiftViewModel.locationInfoUrl;
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Can not launch $url';
          }
        },
      ));
    }
    result.add(ListTile(
      title: Text("Arbeitsbereich"),
      subtitle: Text(
        _shiftViewModel.workAreaLabel,
        style: TextStyle(fontSize: 18),
      ),
    ));

    if (_shiftViewModel.isVotePossible) {
      result.add(ShiftVoteButtonBar(
        shiftVote: _shiftViewModel.shiftVote,
        onActionFinished: () {
          _loadShiftInfo();
        },
      ));
      result.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Bewerbungen auf diesen Dienst sind noch möglich",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ));
    }

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Dienstinformationen"),
      ),
      body: LoaderWidget(
        loading: loading,
        builder: (BuildContext context) {
          List<Widget> widgets = [];
          widgets.add(TitleLable(text: "Details"));
          widgets.addAll(_createShiftInfo());
          widgets.add(Divider());
          widgets.addAll(_createShiftplanInfo());
          widgets.add(Divider());
          widgets.add(TitleLable(text: "Personal"));
          widgets.addAll(_createAssignments());

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          );
        },
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
