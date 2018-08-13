import 'package:blaulichtplaner_app/location_votes/bid_form.dart';
import 'package:blaulichtplaner_app/bid/vote.dart';
import 'package:blaulichtplaner_app/bid/shift_vote.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BidEditor extends StatefulWidget {
  final ShiftVote shiftVote;
  final bool fixedDates;

  const BidEditor({Key key, @required this.shiftVote, this.fixedDates = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BidEditorState();
  }
}

class BidEditorState extends State<BidEditor> {
  final BidModel bidModel = BidModel();

  @override
  void initState() {
    super.initState();
    final shiftVote = widget.shiftVote;
    bidModel.from = shiftVote.from;
    bidModel.to = shiftVote.to;
    if (shiftVote.bid != null) {
      final bid = shiftVote.bid;
      bidModel.remarks = bid.remarks;
      bidModel.minHours = bid.minHours;
      bidModel.maxHours = bid.maxHours;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Dienstbewerbung")),
        body: SingleChildScrollView(
            child: BidForm(
          bidModel: bidModel,
          saveBid: (bidModel, ctx) {
            Bid bid = widget.shiftVote.hasBid() ? widget.shiftVote.bid : Bid();
            bid.from = bidModel.from;
            bid.to = bidModel.to;
            if (bid.to.isBefore(bid.from)) {
              Scaffold.of(ctx).showSnackBar(SnackBar(
                    content: Text('End- sollte vor Startzeitpunkt liegen.'),
                  ));
              return;
            }
            bid.remarks = bidModel.remarks;
            bid.minHours = bidModel.minHours;
            bid.maxHours = bidModel.maxHours;
            if (bid.minHours > bid.maxHours) {
              Scaffold.of(ctx).showSnackBar(SnackBar(
                    content: Text(
                        'Maximaldauer sollte über der Minimaldauer liegen.'),
                  ));
              return;
            }

            if (widget.shiftVote.hasShift()) {
              Shift shift = widget.shiftVote.shift;
              bid.shiftRef = shift.shiftRef;
            }

            bid.shiftplanRef = widget.shiftVote.shiftplanRef;

            Role role = UserManager.get().getRoleForTypeAndReference(
                "employee", widget.shiftVote.shiftplanRef);

            if (role == null) {
              Scaffold.of(ctx).showSnackBar(SnackBar(
                    content:
                        Text('Sie können sich als Manager nicht bewerben.'),
                  ));
              return;
            }

            bid.employeeRef = role.reference;
            bid.employeeLabel = UserManager.get().user != null
                ? UserManager.get().user.displayName
                : "Kein Label";

            BidService bidService = BidService();
            bidService.save(bid).then((ref) {
              Navigator.pop(ctx);
            });
          },
        )));
  }
}
