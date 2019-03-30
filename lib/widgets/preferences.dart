import 'package:blaulichtplaner_app/auth/authentication.dart';
import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class Preferences extends StatefulWidget {
  @override
  PreferencesState createState() {
    return new PreferencesState();
  }
}

class PreferencesState extends State<Preferences> {
  final List<SettingConfig> configs = [
    SettingConfig('Benachrichtigung: ', 'Benachrichtigung via Smartphone',
        'notifications'),
    SettingConfig('E-Mail Benachrichtigungen: ', 'Benachrichtigung via E-Mail',
        'emailNotifications'),
  ];
  BlpUser user = UserManager.instance.user;

  bool emailNotificationValueState;
  bool notificationsValueState;
  DocumentReference notificationsReference;

    @override
    void initState() {
      super.initState();
      notificationsReference = _getDocumentReference();
    }

    _getDocumentReference() {
      Firestore firestore = FirestoreImpl.instance;
      DocumentReference notificationsReference = firestore
          .collection('users')
          .document(user.uid)
          .collection('settings')
          .document('notifications');
      _updateNotificationListener(notificationsReference);
      return notificationsReference;
    }

  _notificationSettingsUpdater(String notificationName, bool value) {
    notificationsReference.setData({notificationName: value}, merge: true);
  }

  _updateNotificationListener(reference) {
    reference.snapshots.listen(
      (DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          setState(
            () {
              for (SettingConfig item in configs) {
                bool value = snapshot.data[item.settingName];
                if (value != null) {
                  item.value = value;
                }
              }
            },
          );
        } else {
          setState(() {
            for (SettingConfig item in configs) {
              item.value = true;
            }
          });
        }
      },
    );
  }

    _settingsListBuilder() {
      List<Widget> notificationSettingList = configs.map(_settingRow).toList();
      return ListView(
        padding: const EdgeInsets.all(0),
        children: notificationSettingList,
      );
    }

  Widget _settingRow(SettingConfig config) {
    return ListTile(
      title: Text(config.title),
      subtitle: Text(config.subTitle),
      trailing: Checkbox(
          value: config.value,
          onChanged: (value) {
            _notificationSettingsUpdater(config.settingName, value);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Benachrichtigung Einstellungen')),
      body: LoaderWidget(
          padding: EdgeInsets.all(0),
          loading: notificationsReference == null,
          child: _settingsListBuilder()),
    );
  }
}

class SettingConfig {
  final String title;
  final String subTitle;
  final String settingName;
  bool value = true;

  SettingConfig(this.title, this.subTitle, this.settingName);
}
