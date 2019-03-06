import 'package:blaulichtplaner_app/shift/shift_view.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_vote_button_bar.dart';
import 'package:blaulichtplaner_app/shift_vote/shift_vote_message.dart';
import 'package:blaulichtplaner_app/utils/utils.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ShiftVotesView extends StatelessWidget {
  final List<ShiftVote> shiftVotes;
  final dateFormatter = DateFormat.EEEE("de_DE").add_yMd();
  final timeFormatter = DateFormat.Hm("de_DE");

  ShiftVotesView({Key key, @required this.shiftVotes}) : super(key: key);

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

    if (shiftVote.hasShift() && !shiftVote.hasAssignment()) {
      if (shiftVote.shift.isVotingPossible()) {
        rows.add(ShiftVoteButtonBar(
          shiftVote: shiftVote,
        ));
      } else {
        rows.add(ShiftVoteMessage(
          shift: shiftVote.shift,
        ));
      }
    }

    return Card(
      child: InkWell(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ShiftViewWidget(
              shiftRef: shiftVote.shiftRef,
              currentEmployeeRef: shiftVote.employeeRef,
            );
          }));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: shiftVotes.length, itemBuilder: _listElementBuilder);
  }
}
