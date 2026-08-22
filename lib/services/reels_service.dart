import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/collections.dart';

class ReelsService {
  Query getActiveReelsQuery() {
    return reelsCollection
        .where("active", isEqualTo: true)
        .orderBy('createdAt', descending: true);
  }

  Future<void> likeReel(String reelId, String uid) async {
    await reelsCollection.doc(reelId).collection("likes").doc(uid).set({
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> unlikeReel(String reelId, String uid) async {
    await reelsCollection.doc(reelId).collection("likes").doc(uid).delete();
  }

  Stream<DocumentSnapshot> getLikeStream(String reelId, String uid) {
    return reelsCollection.doc(reelId).collection("likes").doc(uid).snapshots();
  }

  Future<void> addComment(String reelId, String text, String uid) async {
    await reelsCollection.doc(reelId).collection("comments").add({
      "uid": uid,
      "comment": text,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Query getCommentsQuery(String reelId) {
    return reelsCollection
        .doc(reelId)
        .collection("comments")
        .orderBy("createdAt", descending: true);
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return usersCollection.doc(uid).get();
  }

  Future<void> followUser(String currentUid, String targetUid) async {
    await usersCollection
        .doc(targetUid)
        .collection("followers")
        .doc(currentUid)
        .set({"userID": currentUid, "followedAt": DateTime.now()});
    await usersCollection.doc(targetUid).update({
      "followers": FieldValue.increment(1),
    });

    await usersCollection.doc(currentUid).update({
      "following": FieldValue.increment(1),
    });
    await usersCollection
        .doc(currentUid)
        .collection("following")
        .doc(targetUid)
        .set({"userID": targetUid, "followedAt": DateTime.now()});
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    await usersCollection.doc(targetUid).update({
      "followers": FieldValue.increment(-1),
    });
    await usersCollection
        .doc(targetUid)
        .collection("followers")
        .doc(currentUid)
        .delete();

    await usersCollection.doc(currentUid).update({
      "following": FieldValue.increment(-1),
    });
    await usersCollection
        .doc(currentUid)
        .collection("following")
        .doc(targetUid)
        .delete();
  }

  Stream<DocumentSnapshot> getFollowingStream(
    String currentUid,
    String targetUid,
  ) {
    return usersCollection
        .doc(currentUid)
        .collection("following")
        .doc(targetUid)
        .snapshots();
  }
}
