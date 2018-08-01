import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoaderWidget extends StatelessWidget {
  final bool loading;
  final Widget child;

  const LoaderWidget({Key key, this.loading, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return new Center(
        child: new Column(
          children: <Widget>[CircularProgressIndicator()],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      );
    } else {
      return child;
    }
  }
}
