import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class ConnectionStateWidget extends InheritedWidget {
  const ConnectionStateWidget({
    Key key,
    @required this.connectivityResult,
    @required Widget child,
  }) : super(key: key, child: child);

  final ConnectivityResult connectivityResult;

  static ConnectivityResult of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ConnectionStateWidget)
            as ConnectionStateWidget)
        .connectivityResult;
  }

  @override
  bool updateShouldNotify(ConnectionStateWidget old) =>
      connectivityResult != old.connectivityResult;
}

class ConnectionWidget extends StatelessWidget {
  final Widget child;

  const ConnectionWidget({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConnectivityResult connectivityResult = ConnectionStateWidget.of(context);
    if (connectivityResult == ConnectivityResult.none) {
      return Stack(
        children: <Widget>[
          child,
          Container(
            constraints: BoxConstraints.tightFor(width: double.infinity),
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Die App hat keine Internetverbindung.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else {
      return child;
    }
  }
}
