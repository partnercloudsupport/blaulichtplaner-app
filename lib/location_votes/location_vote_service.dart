import 'dart:async';

import 'package:blaulichtplaner_app/firestore/firestore_flutter.dart';
import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';

class UserVoteService {
  Future<void> save(UserVote userVote, BlpUser user) async {
    WriteBatch batch;
    try {
      CollectionReference locationVotesRef =
          FirestoreImpl.instance.collection('locationVotes');
      CollectionReference userVotesRef = FirestoreImpl.instance
          .collection('users')
          .document(user.uid)
          .collection('votes');

      QuerySnapshot documentsSnapshot = await locationVotesRef
          .where("userVoteRef", isEqualTo: userVote.selfRef)
          .getDocuments();
      List<DocumentSnapshot> documents = documentsSnapshot.documents;

      if (userVote.databaseOperation == DatabaseOperation.setData) {
        print("setData");
        batch = FirestoreImpl.instance.batch()
          ..setData(userVotesRef.document(), userVote.toFirebaseData());
        for (UserVoteLocationItem location in userVote.locations) {
          batch.setData(locationVotesRef.document(),
              LocationVote.fromUserVote(userVote, location).toFirebaseData());
        }
        await batch.commit();
        return;
      } else if (userVote.databaseOperation == DatabaseOperation.updateData) {
        print("updateData");
        batch = FirestoreImpl.instance.batch()
          ..updateData(userVote.selfRef, userVote.toFirebaseData());
        for (UserVoteLocationItem location in userVote.locations) {
          switch (location.databaseOperation) {
            case DatabaseOperation.keepData:
              break;
            case DatabaseOperation.deleteData:
              DocumentSnapshot doc = documents.firstWhere(
                  (DocumentSnapshot s) =>
                      s.data["locationRef"].path == location.locationRef.path,
                  orElse: () => null);
              if (doc != null) {
                batch.delete(doc.reference);
              }
              break;
            case DatabaseOperation.updateData:
              DocumentSnapshot doc = documents.firstWhere(
                  (DocumentSnapshot s) =>
                      s.data["locationRef"].path == location.locationRef.path,
                  orElse: () => null);
              if (doc != null) {
                batch.updateData(
                    doc.reference,
                    LocationVote.fromUserVote(userVote, location)
                        .toFirebaseData());
              }
              break;
            case DatabaseOperation.setData:
              batch.setData(
                  locationVotesRef.document(),
                  LocationVote.fromUserVote(userVote, location)
                      .toFirebaseData());
              break;
          }
        }
        await batch.commit();
        return;
      } else if (userVote.databaseOperation == DatabaseOperation.deleteData) {
        print("deleteData");
        batch = FirestoreImpl.instance.batch()..delete(userVote.selfRef);
        for (UserVoteLocationItem location in userVote.locations) {
          switch (location.databaseOperation) {
            case DatabaseOperation.setData:
              continue;
              break;
            case DatabaseOperation.deleteData:
            case DatabaseOperation.keepData:
            case DatabaseOperation.updateData:
              DocumentSnapshot doc = documents.firstWhere(
                  (DocumentSnapshot s) =>
                      s.data["locationRef"].path == location.locationRef.path,
                  orElse: () => null);
              if (doc != null) {
                batch.delete(doc.reference);
              }
              break;
          }
        }
        await batch.commit();
        return;
      } else {
        return;
      }
    } catch (e) {
      print("location vote $e");
    }
  }
}

class UserVoteHolder {
  List<UserVote> _userVotes;
  UserVoteHolder() : _userVotes = List();
  void add(UserVote vote) {
    _userVotes.add(vote);
    _userVotes.sort((UserVote a, UserVote b) => a.to.compareTo(b.to));
  }

  void modify(UserVote vote) {
    int index =
        _userVotes.indexWhere((UserVote old) => old.selfRef == vote.selfRef);
    if (index >= 0) {
      _userVotes[index] = vote;
    }
    _userVotes.sort((UserVote a, UserVote b) => a.to.compareTo(b.to));
  }

  void remove(UserVote vote) {
    int index =
        _userVotes.indexWhere((UserVote old) => old.selfRef == vote.selfRef);
    if (index >= 0) {
      _userVotes.removeAt(index);
    }
  }

  get isEmpty => _userVotes.isEmpty;

  List<UserVote> get userVotes => _userVotes;
}
