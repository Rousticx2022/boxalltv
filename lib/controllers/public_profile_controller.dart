import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../services/ads_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';

class PublicProfileController extends GetxController {
  String? userID = Get.parameters["userID"];
  RxBool isFollowing = false.obs;
  RxMap userData = {}.obs;
  String uid = "";

  Stream<Map> fetchUser() {
    Stream data = usersCollection.doc(userID).snapshots();
    return data.map((doc) => {
          "name": doc["name"],
          "followers": doc["followers"],
          "thumbnail": doc["thumbnail"],
          "profileImage": doc["profileImage"],
        });
  }

  confirmDelete(String postID) {
    Get.defaultDialog(
        title: "Delete Post",
        titleStyle: fontHeading(
            fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
        content: Text(
          "Are you sure you want to delete this post?",
          style: fontBody(),
          textAlign: TextAlign.center,
        ),
        barrierDismissible: false,
        backgroundColor: kGreyColor2,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: kButtonColor,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Close",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
          TextButton(
            onPressed: () async {
              await postsCollection.doc(postID).update({"active": false});
              Get.back();
              customSnackBar(text: "Post deleted successfully");
            },
            style: TextButton.styleFrom(
              backgroundColor: kButtonColor,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Delete",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        ]);
  }

  fetchFollowingStatus() async {
    DocumentSnapshot documentSnapshot = await usersCollection
        .doc(uid)
        .collection("following")
        .doc(userID)
        .get();

    if (documentSnapshot.exists) {
      isFollowing.value = true;
    } else {
      isFollowing.value = false;
    }
  }

  toggleFollowingStatus() async {
    Get.find<AdsService>().showRewardedAd(1);
    if (isFollowing.value) {
      isFollowing.value = false;
      await usersCollection.doc(userID).update({
        "followers": FieldValue.increment(-1),
      });
      await usersCollection
          .doc(userID)
          .collection("followers")
          .doc(uid)
          .delete();

      await usersCollection.doc(uid).update({
        "following": FieldValue.increment(-1),
      });
      await usersCollection
          .doc(uid)
          .collection("following")
          .doc(userID)
          .delete();
    } else {
      isFollowing.value = true;
      await usersCollection.doc(userID).collection("followers").doc(uid).set({
        "userID": uid,
        "followedAt": DateTime.now(),
      });
      await usersCollection.doc(userID).update({
        "followers": FieldValue.increment(1),
      });

      await usersCollection.doc(uid).update({
        "following": FieldValue.increment(1),
      });
      await usersCollection.doc(uid).collection("following").doc(userID).set({
        "userID": userID,
        "followedAt": DateTime.now(),
      });
    }
  }

  @override
  void onInit() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    userData.bindStream(fetchUser());
    fetchFollowingStatus();
    super.onInit();
  }

}
