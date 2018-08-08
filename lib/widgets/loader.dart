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
      this.loading,
      this.padding = const EdgeInsets.all(0.0),
      this.child})
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

class LoaderScaffoldWidget extends StatelessWidget {
  final bool loading;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const LoaderScaffoldWidget(
      {Key key,
      this.loading,
      this.padding = const EdgeInsets.all(0.0),
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Padding(
          padding: padding,
          child: Center(
            child: Column(
              children: <Widget>[CircularProgressIndicator()],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),
      );
    } else {
      return child;
    }
  }
}
