import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Loadable<T> {
  T data;
  bool loading = false;

  Loadable(this.data);
}

class LoaderWidget extends StatelessWidget {
  final bool loading;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const LoaderWidget(
      {Key key,
      @required this.loading,
      this.padding = const EdgeInsets.all(0.0),
      @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: padding,
        child: Center(
          child: Column(
            children: <Widget>[CircularProgressIndicator()],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      );
    } else {
      return child;
    }
  }
}

class LoaderBodyWidget extends StatelessWidget {
  final bool loading;
  final Widget child;
  final bool empty;
  final String fallbackText;
  final Widget fallbackWidget;

  const LoaderBodyWidget({
    Key key,
    @required this.loading,
    @required this.child,
    @required this.empty,
    this.fallbackText,
    this.fallbackWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: <Widget>[CircularProgressIndicator()],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ));
    } else {
      if (empty) {
        return fallbackWidget ?? Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: <Widget>[Text(fallbackText, textAlign: TextAlign.center,)],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        );
      } else {
        return child;
      }
    }
  }
}
