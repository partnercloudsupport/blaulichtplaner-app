import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/utils/utils.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:blaulichtplaner_app/widgets/no_employee.dart';
import 'package:logging/logging.dart';

class ShiftVotesView extends StatefulWidget {
  final List<CompanyEmployeeRole> employeeRoles;
  final FilterConfig filterConfig;

  ShiftVotesView({
    Key key,
    @required this.employeeRoles,
    @required this.filterConfig,
  });

  bool hasEmployeeRoles() {
    return employeeRoles != null && employeeRoles.isNotEmpty;
  }

  @override
  ShiftVotesViewState createState() {
    return ShiftVotesViewState();
  }
}

class ShiftVotesViewState extends State<ShiftVotesView> {
  ShiftVoteHolder _shiftVoteHolder;
  bool _initialized = false;
  List<ShiftVote> shiftVotes;

  @override
  void initState() {
    super.initState();
    _initDataListeners();
  }

  void _initDataListeners() async {
    _shiftVoteHolder =
        ShiftVoteHolder(widget.employeeRoles, FirestoreImpl.instance, () {
      setState(() {
        shiftVotes = _shiftVoteHolder.shiftVotes;
      });
    });
    await _shiftVoteHolder.initListeners();
    setState(() {
      _initialized = true;
    });
  }

  @override
  void didUpdateWidget(ShiftVotesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _initialized = false;
    });
    _shiftVoteHolder.cancelSubscriptions();
    _shiftVoteHolder.clear();
    _initDataListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _shiftVoteHolder.cancelSubscriptions();
  }

  Widget createInfoBox(String text, IconData iconData) {
    return Padding(
        padding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              iconData,
              size: 24.0,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  text,
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _listElementBuilder(BuildContext context, int index) {
    ShiftVote shiftVote = shiftVotes[index];

    final dateFormatter = DateFormat.EEEE("de_DE").add_yMd();
    final timeFormatter = DateFormat.Hm("de_DE");

    String dateTimeLabel = dateFormatter.format(shiftVote.from);

    final shiftDuration = shiftVote.shiftDuration();
    int shiftHours = shiftDuration.inHours;
    final minutesDuration = shiftDuration - Duration(hours: shiftHours);
    int shiftMinutes = minutesDuration.inMinutes;

    String shiftDurationLabel = shiftHours.toString() +
        "h" +
        (shiftMinutes > 0 ? (" " + shiftMinutes.toString() + "m") : "");

    String timeTimeLabel = timeFormatter.format(shiftVote.from) +
        " - " +
        timeFormatter.format(shiftVote.to) +
        " (" +
        shiftDurationLabel +
        ")";

    List<FlatButton> buttons = [];
    if (shiftVote.isBid) {
      buttons.add(FlatButton(
        child: Text('Bewerbung löschen'),
        onPressed: () async {
          try {
            EmployeeShiftVoteDelete action =
                EmployeeShiftVoteDelete(FirestoreImpl.instance);
            await action.performAction(shiftVote);

            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Bewerbung gelöscht.'),
            ));
          } catch (e) {
            print(e);
          }
        },
      ));
    } else if (shiftVote.isRejected) {
      buttons.add(FlatButton(
        child: Text('Ablehnung löschen'),
        onPressed: () async {
          try {
            EmployeeShiftVoteDelete action =
                EmployeeShiftVoteDelete(FirestoreImpl.instance);
            await action.performAction(shiftVote);

            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Ablehnung gelöscht.'),
            ));
          } catch (e) {
            print(e);
          }
        },
      ));
    } else {
      buttons.add(FlatButton(
        textColor: Colors.red,
        child: Text('Ablehnen'),
        onPressed: () async {
          EmployeeShiftVoteSave action =
              EmployeeShiftVoteSave(FirestoreImpl.instance);
          await action.performAction(ShiftVoteAction(shiftVote, false));
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Ablehnung gespeichert.'),
          ));
        },
      ));
      buttons.add(FlatButton(
        child: Text('Bewerben'),
        onPressed: () async {
          EmployeeShiftVoteSave action =
              EmployeeShiftVoteSave(FirestoreImpl.instance);
          await action.performAction(ShiftVoteAction(shiftVote, true));

          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Bewerbung gespeichert.'),
          ));
        },
      ));
    }

    IconData icon = Icons.help;
    Color color = Colors.grey;
    if (shiftVote.isBid) {
      icon = Icons.check;
      color = Colors.green;
    } else if (shiftVote.isRejected) {
      icon = Icons.close;
      color = Colors.red;
    }
    List<Widget> rows = <Widget>[
      ListTile(
        title: Text(dateTimeLabel),
        subtitle: Text(timeTimeLabel),
        contentPadding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
        trailing: Icon(
          icon,
          color: color,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Wrap(
          children: <Widget>[
            Chip(
              label: Text('${shiftVote.workAreaLabel}'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Chip(
                label: Text('${shiftVote.locationLabel}'),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.black.withAlpha(0x1f),
                        width: 1.0,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(28.0)),
              ),
            ),
          ],
        ),
      ),
    ];

    if (shiftVote.hasShift() && isNotEmpty(shiftVote.shift.publicNote)) {
      rows.add(createInfoBox(shiftVote.shift.publicNote, Icons.assignment));
    }

    rows.add(ButtonTheme.bar(
      // make buttons use the appropriate styles for cards
      child: ButtonBar(
        children: buttons,
      ),
    ));

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  _fallbackText() {
    switch (widget.filterConfig.option) {
      case FilterOption.rejected:
        return 'Keine abgelehnten Dienste';
      case FilterOption.accepted:
        return 'Keine Dienste mit Bewerbung';
      case FilterOption.withoutVote:
        return 'Keine unbesetzten Dienste';
    }
  }

  List<ShiftVote> filterShiftVotes() {
    List<ShiftVote> unfilteredShiftVotes = _shiftVoteHolder.shiftVotes;
    List<ShiftVote> filteredShifts =
        unfilteredShiftVotes.where(widget.filterConfig.filter).toList();
    return filteredShifts;
  }

  @override
  Widget build(BuildContext context) {
    shiftVotes = filterShiftVotes();
    if (widget.hasEmployeeRoles()) {
      return LoaderBodyWidget(
        loading: !_initialized,
        child: ListView.builder(
            itemCount: shiftVotes.length, itemBuilder: _listElementBuilder),
        fallbackText: _fallbackText(),
        empty: shiftVotes.isEmpty,
      );
    } else {
      return NoEmployee();
    }
  }
}
