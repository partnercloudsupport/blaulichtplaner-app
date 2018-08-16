import 'dart:async';

import 'package:blaulichtplaner_app/location_votes/location_vote.dart';
import 'package:blaulichtplaner_app/utils/user_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

        QuerySnapshot documentsSnapshot = await locationVotesRef
            .where("userVoteRef", isEqualTo: userVote.selfRef)
            .getDocuments();
        List<DocumentSnapshot> documents = documentsSnapshot.documents;

        if (userVote.databaseOperation == DatabaseOperation.setData) {
          print("setData");
          batch = Firestore.instance.batch()
            ..setData(userVotesRef.document(), userVote.toFirebaseData());
          for (UserVoteLocationItem location in userVote.locations) {
            batch.setData(locationVotesRef.document(),
                LocationVote.fromUserVote(userVote, location).toFirebaseData());
          }
          await batch.commit();
          return;
        } else if (userVote.databaseOperation == DatabaseOperation.updateData) {
          print("updateData");
          batch = Firestore.instance.batch()
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
                      LocationVote
                          .fromUserVote(userVote, location)
                          .toFirebaseData());
                }
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
          await batch.commit();
          return;
        } else if (userVote.databaseOperation == DatabaseOperation.deleteData) {
          print("deleteData");
          batch = Firestore.instance.batch()..delete(userVote.selfRef);
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
        print(e);
      }
    } else {
      print('Can not get user');
    }
  }
}

class UserVoteHolder {
  List<UserVote> _userVotes;
  UserVoteHolder() : _userVotes = List();
  void add(UserVote vote) {
    _userVotes.add(vote);
    _userVotes.sort((UserVote a, UserVote b) => a.from.compareTo(b.from));
  }

  void modify(UserVote vote) {
    int index =
        _userVotes.indexWhere((UserVote old) => old.selfRef == vote.selfRef);
    if (index >= 0) {
      _userVotes[index] = vote;
    }
    _userVotes.sort((UserVote a, UserVote b) => a.from.compareTo(b.from));
  }

  void remove(UserVote vote) {
    int index =
        _userVotes.indexWhere((UserVote old) => old.selfRef == vote.selfRef);
    if (index >= 0) {
      _userVotes.removeAt(index);
    }
    _userVotes.sort((UserVote a, UserVote b) => a.from.compareTo(b.from));
  }

  List<UserVote> get userVotes => _userVotes;
}
