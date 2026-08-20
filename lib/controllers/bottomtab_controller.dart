import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:boxalltv/views/tabs/musics_tab.dart';
import 'package:boxalltv/views/tabs/reels_tab.dart';
import 'package:boxalltv/views/tabs/socials_tab.dart';
import 'package:boxalltv/views/tabs/stream_tab.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../services/ads_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';
import 'package:http/http.dart' as http;

class BottomTabController extends GetxController with WidgetsBindingObserver {
  var selectedIndex = 0.obs;
  String? uid = Get.parameters["uid"];
  var loading = true.obs;
  DateTime? currentBackPressTime;
  final box = GetStorage();

  RxInt cartItems = 0.obs;
  RxInt unreadNotifications = 0.obs;
  RxMap userData = {}.obs;

  List tabs = [];

  Future<void> requestPermissions() async {
    await Permission.notification.request();

    await Permission.mediaLibrary.request();
    if (await Permission.storage.request().isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.photos.request().isDenied) {
      await Permission.photos.request();
    }
    if (await Permission.videos.request().isDenied) {
      await Permission.videos.request();
    }
    if (await Permission.microphone.request().isDenied) {
      await Permission.microphone.request();
    }
  }

  Stream<int> fetchUserCartItems() {
    return usersCollection.doc(uid).collection("cart").snapshots().map((snapshot) {
      return snapshot.size;
    });
  }

  Stream<int> fetchUnreadNotifications() {
    return usersCollection.doc(uid).collection("notifications").where("unread", isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.size;
    });
  }

  Stream<Map> fetchUserData() {
    Stream data = usersCollection.doc(uid).snapshots();
    return data.map(
      (doc) => {
        "profileImage": doc["profileImage"],
        "name": doc["name"],
        "wallet": doc["wallet"],
        "email": doc["email"],
        "zipcode": doc["zipcode"],
        "accountType": doc["accountType"],
        "recommendations": doc["recommendations"],
        "subscribed": doc["subscribed"],
        "subscriptionDuration": doc["subscriptionDuration"],
        "bankDetails": doc["bankDetails"],
      },
    );
  }

  void shareSocialPosts(String pid, List fileURLs) async {
    Get.dialog(customCircularProgress(strokeColor: kSocialPrimaryColor), barrierDismissible: false);

    List<XFile> xFiles = [];

    for (Map file in fileURLs) {
      try {
        var response = await http.get(Uri.parse(file["url"]));
        final cacheDirectory = (await getTemporaryDirectory()).path;
        File imgFile = File('$cacheDirectory/${DateTime.now().millisecondsSinceEpoch}.${file["type"] == "video" ? "mp4" : "png"}');
        imgFile.writeAsBytesSync(response.bodyBytes);

        xFiles.add(XFile(imgFile.path));
      } catch (e) {
        customSnackBar(text: e.toString());
      }
    }
    await postsCollection.doc(pid).update({"shares": FieldValue.increment(1)});
    Get.back();
    Share.shareXFiles(xFiles);
  }

  @override
  void onInit() {
    tabs = [StreamTab(uid: uid!), SocialsTab(uid: uid!), ReelsTab(uid: uid!), MusicsTab(uid: uid!)];
    initialCheck();
    requestPermissions();

    super.onInit();
  }

  Future<void> initialCheck() async {
    WidgetsBinding.instance.addObserver(this);
    userData.bindStream(fetchUserData());
    UserService.instance.updateToken(uid!);
    UserService.instance.checkSubscription(uid: uid!);

    cartItems.bindStream(fetchUserCartItems());
    unreadNotifications.bindStream(fetchUnreadNotifications());
    loading.value = false;

    // QuerySnapshot users = await usersCollection.get();
    // for (DocumentSnapshot user in users.docs) {
    //   user.reference.update({"zipcode": ""});
    // }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      customSnackBar(text: "Back again to exit!");

      return Future.value(false);
    }
    return Future.value(true);
  }

  RxInt selectedSeasonIndex = 1.obs;

  Future<bool> updateContinueWatching({
    required int position,
    required int duration,
    required String section,
    String episodeID = "",
    required String vid,
    required int adsCount,
    required String type,
  }) async {
    if (position < 2000000) return true;
    String docID = section == "series" ? "${vid}_$episodeID" : vid;
    DocumentSnapshot data = await usersCollection.doc(uid).collection("continueWatching").doc(docID).get();
    if (data.exists) {
      await usersCollection.doc(uid).collection("continueWatching").doc(docID).update({"position": position, "lastPlayed": DateTime.now(), "type": type});
    } else {
      await usersCollection.doc(uid).collection("continueWatching").doc(docID).set({
        "position": position,
        "duration": duration,
        "section": section,
        "episodeID": episodeID,
        "vid": vid,
        "lastPlayed": DateTime.now(),
        "type": type,
      });
    }
    String month = DateFormat("MMMM yyyy").format(DateTime.now());
    await videoDataCollection.doc(vid).collection("statistics").doc(month).get().then((value) async {
      if (value.exists) {
        await videoDataCollection.doc(vid).collection("statistics").doc(month).update({
          "views": FieldValue.increment(1),
          "sort": DateTime.now(),
          "adsCount": FieldValue.increment(adsCount),
          "watch": FieldValue.increment(position),
        });
      } else {
        await videoDataCollection.doc(vid).collection("statistics").doc(month).set({
          "views": 1,
          "sort": DateTime.now(),
          "watch": position,
          "adsCount": FieldValue.increment(adsCount),
          "year": DateFormat("yyyy").format(DateTime.now()),
          "month": DateFormat("MMMM").format(DateTime.now()),
        });
      }
    });
    return true;
  }

  Future<void> uploadVideoInProfile(String path) async {
    try {
      Get.dialog(progressIndicator(), barrierDismissible: false);
      String? thumbnailData = await VideoThumbnail.thumbnailFile(
        video: path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.WEBP,
        quality: 50,
      );

      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.Res960x540Quality,
        frameRate: 24,
        includeAudio: true,
        deleteOrigin: true, // It's false by default
      );

      FTPConnect ftpConnect = FTPConnect(
        "storage.bunnycdn.com",
        user: const String.fromEnvironment('FTP_USER'),
        pass: const String.fromEnvironment('FTP_PASS'),
      );
      String videoURL = "", thumbnailURL = "", filename = DateTime.now().millisecondsSinceEpoch.toString();
      await ftpConnect.connect();
      await ftpConnect.changeDirectory("trimmed_videos");
      await ftpConnect.createFolderIfNotExist(uid!);
      await ftpConnect.changeDirectory(uid).then((value) async {
        bool videoStatus = await ftpConnect.uploadFileWithRetry(mediaInfo!.file!, pRetryCount: 3, pRemoteName: "trim_$filename.mp4");
        if (videoStatus) {
          videoURL = "https://frametv.b-cdn.net/trimmed_videos/$uid/trim_$filename.mp4";
        }
        bool thumbStatus = await ftpConnect.uploadFileWithRetry(File(thumbnailData!), pRetryCount: 3, pRemoteName: "thumb_$filename.webp");
        if (thumbStatus) {
          thumbnailURL = "https://frametv.b-cdn.net/trimmed_videos/$uid/thumb_$filename.webp";
        }

        ftpConnect.disconnect();
      });

      // FirebaseStorage storage = FirebaseStorage.instance;
      // Reference ref = storage.ref("users/$uid/trimmed_videos/trim_${DateTime.now().millisecondsSinceEpoch}.mp4");
      // await ref.putFile(File(path));
      // String url = await ref.getDownloadURL();
      //
      // Reference ref2 = storage.ref("users/$uid/trimmed_videos/thumb_${DateTime.now().millisecondsSinceEpoch}.png");
      // await ref2.putFile(File(thumbnailData!));
      // String url2 = await ref2.getDownloadURL();

      await usersCollection.doc(uid).collection("trimmedVideos").add({
        "url": videoURL,
        "addedAt": DateTime.now(),
        "thumbnail": thumbnailURL,
        "title": "Untitled",
      });
      Get.back();
      Get.back();
      Get.back();
      customSnackBar(text: "Trimmed video saved in profile");
    } catch (e) {
      Get.back();
      customSnackBar(text: "Please try again later!");
    }
  }

  @override
  void onReady() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        NotificationService().showNotifications(message.notification?.title, message.notification?.body);
      }
    });
    //
    Get.put<AdsService>(AdsService());
    super.onReady();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        UserService.instance.toggleActiveStatus(uid!, false);
        break;
      case AppLifecycleState.resumed:
        UserService.instance.toggleActiveStatus(uid!, true);
        break;
    }
  }
}
