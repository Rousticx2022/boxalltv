import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:get/get.dart';
import '../utils/collections.dart';
import 'ads_service.dart';

class UploadService extends GetxService {
  RxBool isReelUploading = false.obs;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  uploadReel({
    required String videoFile,
    required String thumbnail,
    required String caption,
    required bool enableComment,
    required bool enableSharing,
  }) async {
    isReelUploading.value = true;
    String videoURL = "", thumbURL = "";
    try {
      final storageRef = FirebaseStorage.instance.ref();

      int fileName = DateTime.now().millisecondsSinceEpoch;

      try {
        final postRef = storageRef.child("reels/$uid/reel_$fileName.mp4");
        await postRef.putFile(File(videoFile));
        videoURL = await postRef.getDownloadURL();
      } on FirebaseException catch (e) {
        customSnackBar(text: e.code);
      }

      try {
        final postRef = storageRef.child("reels/$uid/reel_$fileName.webp");
        await postRef.putFile(File(thumbnail));
        thumbURL = await postRef.getDownloadURL();
      } on FirebaseException catch (e) {
        customSnackBar(text: e.code);
      }

      await reelsCollection.add({
        "uid": uid,
        "caption": caption.trim(),
        "video": videoURL,
        "thumbnail": thumbURL,
        "enableComment": enableComment,
        "enableSharing": enableSharing,
        "active": true,
        "comments": 0,
        "engagement": 0,
        "likes": 0,
        "shares": 0,
        "createdAt": DateTime.now(),
      });

      // ftpConnect.disconnect();
      isReelUploading.value = false;
      customSnackBar(text: "Reel uploaded successfully");
      Get.find<AdsService>().showRewardedAd(1);
      // });
    } catch (e) {
      debugPrint(e.toString());
      isReelUploading.value = false;
    }
  }
}
