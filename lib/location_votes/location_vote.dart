import 'dart:async';

import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum DatabaseOperation { setData, keepData, updateData, deleteData }

class UserVoteLocationItem {
  DatabaseOperation databaseOperation;
  final String locationLabel;
  final DocumentReference locationRef;
  final DocumentReference employeeRef;
  DocumentReference selfRef;

  UserVoteLocationItem(
    this.locationLabel,
    this.locationRef,
    this.employeeRef,
    this.databaseOperation,
  );
  UserVoteLocationItem.fromSnapshot(
    this.locationLabel,
    this.locationRef,
    this.employeeRef,
    this.databaseOperation,
    this.selfRef,
  ) : assert(selfRef != null);
}

abstract class AbstractLocationVote {
  DateTime _from;
  DateTime _to;
  int _minHours;
  int _maxHours;
  String _remarks;
  DocumentReference selfRef;
  DatabaseOperation databaseOperation;

  AbstractLocationVote() {
    _from = DateTime.now();
    _to = DateTime.now();
    _minHours = 0;
    _maxHours = 0;
    databaseOperation = DatabaseOperation.setData;
  }
  Map<String, dynamic> toFirebaseData();
}

class UserVote extends AbstractLocationVote {
  List<UserVoteLocationItem> locations;

  UserVote()
      : locations = List(),
        super();

  DateTime get from => _from;
  DateTime get to => _to;
  int get minHours => _minHours;
  int get maxHours => _maxHours;
  String get remarks => _remarks;

  set from(DateTime from) {
    _from = from;
    databaseOperation = DatabaseOperation.updateData;
  }

  set to(DateTime to) {
    _to = to;
    databaseOperation = DatabaseOperation.updateData;
  }

  set minHours(int minHours) {
    _minHours = minHours;
    databaseOperation = DatabaseOperation.updateData;
  }

  set maxHours(int maxHours) {
    _maxHours = maxHours;
    databaseOperation = DatabaseOperation.updateData;
  }

  set remarks(String remarks) {
    _remarks = remarks;
    databaseOperation = DatabaseOperation.updateData;
  }

  UserVote.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data;
    _from = data["from"];
    _to = data["from"];
    _minHours = data["minHours"];
    _maxHours = data["maxHours"];
    _remarks = data["remarks"];
    selfRef = snapshot.reference;
    assert(selfRef != null);
    databaseOperation = DatabaseOperation.keepData;

    locations = List();
    for (Map<String, dynamic> location in data["locations"]) {
      locations.add(UserVoteLocationItem.fromSnapshot(
          location["locationLabel"],
          location["locationRef"],
          location["employeeRef"],
          DatabaseOperation.keepData,
          location["locationVoteRef"]));
    }
  }

  void addLocation(
    DocumentReference employeeRef,
    DocumentReference locationRef,
    String locationLabel,
  ) {
    databaseOperation = (databaseOperation == DatabaseOperation.keepData)
        ? DatabaseOperation.updateData
        : databaseOperation;
    assert(databaseOperation != DatabaseOperation.deleteData);

    int index = locations.indexWhere(
        (UserVoteLocationItem item) => item.locationRef == locationRef);
    if (index >= 0) {
      switch (locations[index].databaseOperation) {
        case DatabaseOperation.setData:
        case DatabaseOperation.updateData:
          return;
          break;
        case DatabaseOperation.keepData:
          locations[index].databaseOperation = databaseOperation;
          break;
        case DatabaseOperation.deleteData:
          locations[index].databaseOperation = DatabaseOperation.keepData;
          break;
      }
    } else {
      locations.add(UserVoteLocationItem(
        locationLabel,
        locationRef,
        employeeRef,
        DatabaseOperation.setData,
      ));
    }
  }

  void deleteLocation(
    DocumentReference employeeRef,
    DocumentReference locationRef,
    String locationLabel,
  ) {
    databaseOperation = (databaseOperation == DatabaseOperation.keepData)
        ? DatabaseOperation.updateData
        : databaseOperation;

    int index = locations.indexWhere(
        (UserVoteLocationItem item) => item.locationRef == locationRef);
    if (index >= 0) {
      switch (locations[index].databaseOperation) {
        case DatabaseOperation.deleteData:
          return;
          break;
        case DatabaseOperation.keepData:
        case DatabaseOperation.updateData:
          locations[index].databaseOperation = DatabaseOperation.deleteData;
          break;
        case DatabaseOperation.setData:
          locations.removeAt(index);
          break;
      }
    }
  }

  List<Map<String, dynamic>> _createLocationsMap() {
    List<Map<String, dynamic>> list = List();
    for (UserVoteLocationItem location in locations) {
      list.add({
        "locationLabel": location.locationLabel,
        "locationRef": location.locationRef,
        "employeeRef": location.employeeRef,
        "locationVoteRef": location.selfRef
      });
    }
    return list;
  }

  Map<String, dynamic> toFirebaseData() {
    Map<String, dynamic> data = {
      "from": _from,
      "to": _to,
      "minHours": _minHours,
      "maxHours": _maxHours,
      "remarks": _remarks,
      "locations": _createLocationsMap(),
    };
    return data;
  }
}

class LocationVote extends AbstractLocationVote {
  String locationLabel;
  DocumentReference locationRef;
  DocumentReference employeeRef;
  DocumentReference userVoteRef;
  DocumentReference selfRef;

  LocationVote.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data;
    _from = data["from"];
    _to = data["from"];
    _minHours = data["minHours"];
    _maxHours = data["maxHours"];
    _remarks = data["remarks"];
    locationLabel = data["locationLabel"];
    locationRef = data["locationRef"];
    employeeRef = data["employeeRef"];
    userVoteRef = data["userVoteRef"];
    assert(userVoteRef != null);
    selfRef = snapshot.reference;
    databaseOperation = DatabaseOperation.keepData;
  }

  LocationVote.fromUserVote(UserVote userVote, UserVoteLocationItem location) {
    _from = userVote.from;
    _to = userVote.to;
    _minHours = userVote._minHours;
    _maxHours = userVote.maxHours;
    _remarks = userVote.remarks;
    userVoteRef = userVote.selfRef;
    locationRef = location.locationRef;
    locationLabel = location.locationLabel;
    employeeRef = location.employeeRef;
    databaseOperation = location.databaseOperation;
  }

  Map<String, dynamic> toFirebaseData() {
    Map<String, dynamic> data = {
      "from": _from,
      "to": _to,
      "minHours": _minHours,
      "maxHours": _maxHours,
      "remarks": _remarks,
      "locationLabel": locationLabel,
      "locationRef": locationRef,
      "employeeRef": employeeRef,
      "userVoteRef": userVoteRef
    };
    return data;
  }
}

class UserVoteService {
  Future<void> save(UserVote userVote) async {
    WriteBatch batch;
    FirebaseUser user = UserManager.get().user;
    if (user != null) {
      try {
        CollectionReference locationVotesRef =
            Firestore.instance.collection('locationVotes');
        CollectionReference userVotesRef = Firestore.instance
            .collection('users')
            .document(user.uid)
            .collection('votes');

        switch (userVote.databaseOperation) {
          case DatabaseOperation.keepData:
            break;
          case DatabaseOperation.updateData:
            batch = Firestore.instance.batch()
              ..updateData(userVote.selfRef, userVote.toFirebaseData());
            for (UserVoteLocationItem location in userVote.locations) {
              switch (location.databaseOperation) {
                case DatabaseOperation.keepData:
                  break;
                case DatabaseOperation.deleteData:
                  batch.delete(location.selfRef);
                  break;
                case DatabaseOperation.updateData:
                  batch.updateData(
                      location.selfRef,
                      LocationVote
                          .fromUserVote(userVote, location)
                          .toFirebaseData());
                  break;
                case DatabaseOperation.setData:
                  batch.setData(
                      locationVotesRef.document(),
                      LocationVote
                          .fromUserVote(userVote, location)
                          .toFirebaseData());
                  break;
              }
            }

            break;
          case DatabaseOperation.deleteData:
            batch = Firestore.instance.batch()..delete(userVote.selfRef);
            for (UserVoteLocationItem location in userVote.locations) {
              switch (location.databaseOperation) {
                case DatabaseOperation.setData:
                  continue;
                  break;
                case DatabaseOperation.deleteData:
                case DatabaseOperation.keepData:
                case DatabaseOperation.updateData:
                  batch.delete(location.selfRef);
                  break;
              }
            }
            break;
          case DatabaseOperation.setData:
            batch = Firestore.instance.batch()
              ..setData(userVotesRef.document(), userVote.toFirebaseData());
            break;
        }
        await batch.commit();
      } catch (e) {
        print(e);
      }
    } else {
      throw Exception('Can not get user');
    }
  }
}
