import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:device_info/device_info.dart';

class DeviceInfo {
  final String model;
  final String version;
  final String name;

  DeviceInfo(this.model, this.version, this.name);
}

Future<DeviceInfo> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.model}');
    return DeviceInfo(
        androidInfo.model, androidInfo.version.release, androidInfo.display);
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    print('Running on ${iosInfo.utsname.machine}');
    return DeviceInfo(iosInfo.model, iosInfo.systemVersion, iosInfo.name);
  } else {
    return DeviceInfo('unknown', 'unknown', 'unknown');
  }
}

bool isNotEmpty(String value) {
  return value != null && value.isNotEmpty;
}

Future<void> showErrorDialog(BuildContext context, Exception e) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Fehler"),
        content: Text("Fehler: $e"),
        actions: <Widget>[
          FlatButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}
