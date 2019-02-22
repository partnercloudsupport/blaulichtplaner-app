import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class ShiftVoteButtonBar extends StatelessWidget {
  final ShiftVote shiftVote;
  final Function onActionFinished;

  ShiftVoteButtonBar({Key key, @required this.shiftVote, this.onActionFinished})
      : super(key: key);

  void _showSnackbarAndNotifyActionFinished(
      BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
    if (onActionFinished != null) {
      onActionFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<FlatButton> buttons = [];
    if (shiftVote.isBid) {
      buttons.add(FlatButton(
        child: Text('Bewerbung löschen'),
        onPressed: () async {
          try {
            EmployeeShiftVoteDelete action =
                EmployeeShiftVoteDelete(FirestoreImpl.instance);
            await action.performAction(shiftVote);
            _showSnackbarAndNotifyActionFinished(
                context, 'Bewerbung gelöscht.');
          } catch (e) {
            print(e); // TODO show error message
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
            _showSnackbarAndNotifyActionFinished(
                context, 'Ablehnung gelöscht.');
          } catch (e) {
            print(e); // TODO show error message
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
          _showSnackbarAndNotifyActionFinished(
              context, 'Ablehnung gespeichert.');
        },
      ));
      buttons.add(FlatButton(
        child: Text('Bewerben'),
        onPressed: () async {
          EmployeeShiftVoteSave action =
              EmployeeShiftVoteSave(FirestoreImpl.instance);
          await action.performAction(ShiftVoteAction(shiftVote, true));
          _showSnackbarAndNotifyActionFinished(
              context, 'Bewerbung gespeichert.');
        },
      ));
    }

    return ButtonTheme.bar(
      child: ButtonBar(
        children: buttons,
      ),
    );
  }
}
