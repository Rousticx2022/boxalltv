import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';

class UserService {
  static UserService instance = UserService();
  Future<String> authenticate() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser == null ? "" : auth.currentUser!.uid;
  }

  void updateToken(String uid) async {
    DocumentSnapshot user = await usersCollection.doc(uid).get();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    await firebaseMessaging.getToken().then((token) {
      DateTime validity = DateTime.parse(
        user['subscriptionDuration'].toDate().toString(),
      );

      user.reference.update({
        "messageToken": token,
        "active": true,
        "lastSeen": DateTime.now(),
        "accountType": validity.difference(DateTime.now()).isNegative
            ? "freemium"
            : "premium",
        "subscribed": validity.difference(DateTime.now()).isNegative
            ? false
            : true,
      });
    });
  }

  Future<void> addToCart({
    required String uid,
    required String vid,
    required String productID,
  }) async {
    DocumentSnapshot cartDoc = await usersCollection
        .doc(uid)
        .collection("cart")
        .doc("${vid}_$productID")
        .get();
    if (cartDoc.exists) {
      await usersCollection
          .doc(uid)
          .collection("cart")
          .doc("${vid}_$productID")
          .update({"count": cartDoc["count"] + 1, "lastAdded": DateTime.now()});
    } else {
      await usersCollection
          .doc(uid)
          .collection("cart")
          .doc("${vid}_$productID")
          .set({
            "vid": vid,
            "productID": productID,
            "count": 1,
            "lastAdded": DateTime.now(),
          });
    }
  }

  Future<void> removeFromCart({
    required String uid,
    required String vid,
    required String productID,
  }) async {
    DocumentSnapshot cartDoc = await usersCollection
        .doc(uid)
        .collection("cart")
        .doc("${vid}_$productID")
        .get();

    if (!cartDoc.exists) return;

    if (cartDoc["count"] > 1) {
      await usersCollection
          .doc(uid)
          .collection("cart")
          .doc("${vid}_$productID")
          .update({
            "count": FieldValue.increment(-1),
            "lastAdded": DateTime.now(),
          });
    } else {
      await usersCollection
          .doc(uid)
          .collection("cart")
          .doc("${vid}_$productID")
          .delete();
    }
  }

  void toggleActiveStatus(String uid, bool status) async {
    await usersCollection.doc(uid).update({
      "active": status,
      "lastSeen": DateTime.now(),
    });
  }

  void updatePhoneNumber(String uid, String phoneNumber) async {
    await usersCollection.doc(uid).update({"phone": phoneNumber});
    Get.back();
    customSnackBar(text: "Phone number updated");
  }

  void checkSubscription({required String uid}) async {
    await usersCollection.doc(uid).get().then((value) async {
      DateTime subDuration = value["subscriptionDuration"].toDate();
      if (subDuration.difference(DateTime.now()).isNegative) {
        await usersCollection.doc(uid).update({"subscribed": false});
      }
    });
  }

  void subscribeUser({required String uid, required int days}) async {
    await usersCollection.doc(uid).update({
      "subscribed": true,
      "accountType": "premium",
      "subscriptionDuration": DateTime.now().add(Duration(days: days)),
    });
    Get.back();
    customSnackBar(text: "Subscribed successfully");
  }

  Future<bool> resetPassword(String email) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        customSnackBar(text: "Account not found");
      } else if (e.code == 'invalid-email') {
        customSnackBar(text: "Email address is invalid");
      }
      return false;
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    customSnackBar(text: "Signed out");

    Get.offAllNamed("/login");
  }
}
