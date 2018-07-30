import 'package:blaulichtplaner_app/bid/bid_form.dart';
import 'package:blaulichtplaner_app/bid/bid_service.dart';
import 'package:blaulichtplaner_app/bid/shift_bids.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BidEditor extends StatefulWidget {
  final ShiftBid shiftBid;
  final bool fixedDates;

  const BidEditor({Key key, @required this.shiftBid, this.fixedDates = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new BidEditorState();
  }
}

class BidEditorState extends State<BidEditor> {
  final BidModel bidModel = BidModel();

  @override
  void initState() {
    super.initState();
    final shiftBid = widget.shiftBid;
    bidModel.from = shiftBid.from;
    bidModel.to = shiftBid.to;
    if (shiftBid.bid != null) {
      final bid = shiftBid.bid;
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
          saveBid: (bidModel) {
            Bid bid = widget.shiftBid.hasBid() ? widget.shiftBid.bid : Bid();
            bid.from = bidModel.from;
            bid.to = bidModel.to;
            bid.remarks = bidModel.remarks;
            bid.minHours = bidModel.minHours;
            bid.maxHours = bidModel.maxHours;

            if (widget.shiftBid.hasShift()) {
              Shift shift = widget.shiftBid.shift;
              bid.shiftRef = shift.shiftRef;
            }

            bid.shiftplanRef = widget.shiftBid.shiftplanRef;

            final role = UserManager.get().getRoleForTypeAndReference(
                "employee", widget.shiftBid.shiftplanRef);

            bid.employeeRef = role.reference;
            bid.employeeLabel = "TODO"; // TODO

            BidService bidService = BidService();
            bidService.saveBid(bid).then((ref) {
              Navigator.pop(context);
            });
          },
        )));
  }
}
