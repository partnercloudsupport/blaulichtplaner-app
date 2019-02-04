import 'package:blaulichtplaner_lib/blaulichtplaner.dart';


enum DatabaseOperation { setData, keepData, updateData, deleteData }

class UserVoteLocationItem {
  DatabaseOperation databaseOperation;
  final String locationLabel;
  final DocumentReference locationRef;
  final DocumentReference employeeRef;

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
  );
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
    _to = DateTime.now().add(Duration(days: 1));
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
    if (databaseOperation != DatabaseOperation.setData) {
      databaseOperation = DatabaseOperation.updateData;
    }
  }

  set to(DateTime to) {
    _to = to;
    if (databaseOperation != DatabaseOperation.setData) {
      databaseOperation = DatabaseOperation.updateData;
    }
  }

  set minHours(int minHours) {
    _minHours = minHours;
    if (databaseOperation != DatabaseOperation.setData) {
      databaseOperation = DatabaseOperation.updateData;
    }
  }

  set maxHours(int maxHours) {
    _maxHours = maxHours;
    if (databaseOperation != DatabaseOperation.setData) {
      databaseOperation = DatabaseOperation.updateData;
    }
  }

  set remarks(String remarks) {
    _remarks = remarks;
    if (databaseOperation != DatabaseOperation.setData) {
      databaseOperation = DatabaseOperation.updateData;
    }
  }

  UserVote.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data;
    _from = data["from"];
    _to = data["to"];
    _minHours = data["minHours"];
    _maxHours = data["maxHours"];
    _remarks = data["remarks"];
    selfRef = snapshot.reference;
    assert(selfRef != null);
    databaseOperation = DatabaseOperation.keepData;

    locations = List();
    for (Map<dynamic, dynamic> location in data["locations"]) {
      locations.add(UserVoteLocationItem.fromSnapshot(
          location["locationLabel"],
          location["locationRef"],
          location["employeeRef"],
          DatabaseOperation.keepData));
    }
  }

  void addLocation(
    DocumentReference employeeRef,
    DocumentReference locationRef,
    String locationLabel,
  ) {
    if ((databaseOperation == DatabaseOperation.keepData)) {
      databaseOperation = DatabaseOperation.updateData;
    }
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
          locations[index].databaseOperation =
              databaseOperation == DatabaseOperation.deleteData
                  ? DatabaseOperation.deleteData
                  : DatabaseOperation.keepData;
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
    if ((databaseOperation == DatabaseOperation.keepData)) {
      databaseOperation = DatabaseOperation.updateData;
    }

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
        "employeeRef": location.employeeRef
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
    _to = data["to"];
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
