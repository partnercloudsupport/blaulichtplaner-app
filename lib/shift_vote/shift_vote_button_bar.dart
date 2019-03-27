import 'package:blaulichtplaner_app/auth/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class ShiftVoteButtonBar extends StatefulWidget {
  final ShiftVote shiftVote;
  final Function onActionFinished;

  ShiftVoteButtonBar({Key key, @required this.shiftVote, this.onActionFinished})
      : super(key: key);

  @override
  _ShiftVoteButtonBarState createState() => _ShiftVoteButtonBarState();
}

class _ShiftVoteButtonBarState extends State<ShiftVoteButtonBar> {
  bool loading = false;

  void _showSnackbarAndNotifyActionFinished(
      BuildContext context, String message) {
/*    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));*/
    if (widget.onActionFinished != null) {
      widget.onActionFinished();
    }
  }

  @override
  void didUpdateWidget(ShiftVoteButtonBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    loading = false;
  }

  void _showErrorMessage(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Fehler"),
          content: Text(error),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Function _onPressedFunction(Function action) {
    return () async {
      try {
        setState(() {
          loading = true;
        });
        await action();
      } catch (e) {
        _showErrorMessage(context, e.toString());
      } finally {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    List<FlatButton> buttons = [];
    if (widget.shiftVote.isBid) {
      buttons.add(FlatButton(
        child: Text('Bewerbung löschen'),
        onPressed: _onPressedFunction(() async {
          EmployeeShiftVoteDelete action = EmployeeShiftVoteDelete(
              FirestoreImpl.instance,
              ActionContext(UserManager.instance.user, null, null));
          await action.performAction(widget.shiftVote);
          _showSnackbarAndNotifyActionFinished(context, 'Bewerbung gelöscht.');
        }),
      ));
    } else if (widget.shiftVote.isRejected) {
      buttons.add(FlatButton(
        child: Text('Wieder einblenden'),
        onPressed: _onPressedFunction(() async {
          EmployeeShiftVoteDelete action = EmployeeShiftVoteDelete(
              FirestoreImpl.instance,
              ActionContext(UserManager.instance.user, null, null));
          await action.performAction(widget.shiftVote);
          _showSnackbarAndNotifyActionFinished(context, 'Eingeblendet');
        }),
      ));
    } else {
      buttons.add(FlatButton(
        textColor: Colors.red,
        child: Text('Ausblenden'),
        onPressed: _onPressedFunction(() async {
          EmployeeShiftVoteSave action = EmployeeShiftVoteSave(
              FirestoreImpl.instance,
              ActionContext(UserManager.instance.user, null, null));
          await action.performAction(ShiftVoteAction(widget.shiftVote, false));
          _showSnackbarAndNotifyActionFinished(
              context, 'Ausgeblendet');
        }),
      ));
      buttons.add(FlatButton(
        child: Text('Bewerben'),
        onPressed: _onPressedFunction(() async {
          EmployeeShiftVoteSave action = EmployeeShiftVoteSave(
              FirestoreImpl.instance,
              ActionContext(UserManager.instance.user, null, null));
          await action.performAction(ShiftVoteAction(widget.shiftVote, true));
          _showSnackbarAndNotifyActionFinished(
              context, 'Bewerbung gespeichert.');
        }),
      ));
    }

    return LoaderWidget(
      loading: loading,
      padding: EdgeInsets.all(14.0),
      builder: (BuildContext context) {
        return ButtonTheme.bar(
          child: ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: buttons,
          ),
        );
      },
    );
  }
}
