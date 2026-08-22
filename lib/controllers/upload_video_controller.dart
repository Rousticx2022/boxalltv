import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:get/get.dart';
import '../utils/collections.dart';
import '../utils/exceptions.dart';
import '../utils/ui_widgets.dart';

class UploadVideoController extends GetxController {
  final String uid;

  UploadVideoController({required this.uid});

  Future<void> createReel({
    required String fileName,
    required String videoPath,
    required String thumbnailImagePath,
    required TextEditingController captionController,
    required Map selectedSound,
    String audioPath = "",
  }) async {
    String videoURL = '', thumbnailURL = '', audioURL = '';

    try {
      FTPConnect ftpConnect = FTPConnect(
        "storage.bunnycdn.com",
        user: const String.fromEnvironment('FTP_USER'),
        pass: const String.fromEnvironment('FTP_PASS'),
      );

      await ftpConnect.connect();
      await ftpConnect.changeDirectory("reels");
      await ftpConnect.createFolderIfNotExist(uid);
      await ftpConnect.changeDirectory(uid).then((value) async {
        bool videoStatus = await ftpConnect.uploadFileWithRetry(
          File(videoPath),
          pRetryCount: 3,
          pRemoteName: "reel_$fileName.mp4",
        );
        if (videoStatus) {
          videoURL = "https://frametv.b-cdn.net/reels/$uid/reel_$fileName.mp4";
        }
        bool thumbStatus = await ftpConnect.uploadFileWithRetry(
          File(thumbnailImagePath),
          pRetryCount: 3,
          pRemoteName: "thumbnail_$fileName.webp",
        );
        if (thumbStatus) {
          thumbnailURL =
              "https://frametv.b-cdn.net/reels/$uid/thumbnail_$fileName.webp";
        }
        if (audioPath.isNotEmpty) {
          bool audioStatus = await ftpConnect.uploadFileWithRetry(
            File(audioPath),
            pRetryCount: 3,
            pRemoteName: "audio_$fileName.mp3",
          );
          if (audioStatus) {
            audioURL =
                "https://frametv.b-cdn.net/reels/$uid/audio_$fileName.mp3";
          }
        }

        ftpConnect.disconnect();
      });
    } catch (e) {
      Get.back();
      throw AppException("FTP upload failed", originalException: e);
    }

    try {
      await reelsCollection.add({
        'userID': uid,
        'url': videoURL,
        'thumbnail': thumbnailURL,
        'createdAt': DateTime.now(),
        "hasAudio": audioURL.isNotEmpty,
        "caption": captionController.text,
        "soundData": selectedSound.isEmpty
            ? {}
            : {
                "url": audioURL,
                "id": selectedSound["id"],
                "title": selectedSound["title"],
              },
        'totalLikes': 0,
        'totalComments': 0,
        'totalShares': 0,
      });
      Get.back();
      Get.back();
      customSnackBar(text: "Reel uploaded successfully!");
    } catch (e) {
      Get.back();
      throw AppException(
        "Failed to add reel to Firestore",
        originalException: e,
      );
    }
  }
}
