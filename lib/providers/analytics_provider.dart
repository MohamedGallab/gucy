// user_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AnalyticsProvider with ChangeNotifier {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String currentPage = "Confessions";
  DateTime? lastPageEntryTime;

  Future<void> changePage(String newPage, String uid) async {
    print(newPage + "NEW");
    print(currentPage + "CUrrent");
    await _updateTimeSpentOnPage();
    await _updateTimeSpentOnPageForUser(uid);

    lastPageEntryTime = null;
    currentPage = newPage;
    lastPageEntryTime = DateTime.now();
    notifyListeners();
  }

  Future<void> _updateTimeSpentOnPageForUser(String uid) async {
    var timeSpent = DateTime.now()
        .difference(lastPageEntryTime ?? new DateTime(0))
        .inSeconds;
    final collectionRef = db.collection("analytics");

    final query = collectionRef.where("uid", isEqualTo: uid);
    await query.get().then((querySnapshot) => {
          querySnapshot.docs.forEach((doc) => doc.reference
              .update({currentPage: FieldValue.increment(timeSpent)}))
        });
  }

  Future<void> _updateTimeSpentOnPage() async {
    if (lastPageEntryTime == null) return;
    var timeSpent = DateTime.now()
        .difference(lastPageEntryTime ?? new DateTime(0))
        .inSeconds;
    await db
        .collection('analytics')
        .doc('Global Analytics')
        .update({currentPage: FieldValue.increment(timeSpent)});
  }

  Future<void> clickPost(String post, String uid) async {
    await _updatePost(post);
    await _updatePostForUser(post, uid);
    notifyListeners();
  }

  Future<void> _updatePostForUser(String post, String uid) async {
    final collectionRef = db.collection("analytics");

    final query = collectionRef.where("uid", isEqualTo: uid);
    await query.get().then((querySnapshot) => {
          querySnapshot.docs.forEach(
              (doc) => doc.reference.update({post: FieldValue.increment(1)}))
        });
  }

  Future<void> _updatePost(String post) async {
    if (lastPageEntryTime == null) return;

    await db
        .collection('analytics')
        .doc('Global Analytics')
        .update({currentPage: FieldValue.increment(1)});
  }
}