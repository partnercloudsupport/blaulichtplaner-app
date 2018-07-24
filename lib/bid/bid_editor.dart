import 'package:blaulichtplaner_app/bid/bid_form.dart';
import 'package:blaulichtplaner_app/shift_bids_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BidEditor extends StatefulWidget {
  final Shift shift;
  final bool fixedDates;

  const BidEditor({Key key, @required this.shift, this.fixedDates = true})
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
    Shift shift = widget.shift;
    bidModel.from = shift.from;
    bidModel.to = shift.to;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Dienstbewerbung")),
        body: SingleChildScrollView(
            child: BidForm(
          bidModel: bidModel,
          saveBid: (bidModel) {},
        )));
  }
}
