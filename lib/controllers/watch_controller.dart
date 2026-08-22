import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_screen_recorder/device_screen_recorder.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:boxalltv/services/ads_service.dart';
import 'package:get/get.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:video_player/video_player.dart';

import '../utils/collections.dart';
import 'package:http/http.dart' as http;

import '../views/edit_recorded_video.dart';
import 'bottomtab_controller.dart';

class WatchController extends GetxController with WidgetsBindingObserver {
  String? uid = Get.parameters["uid"],
      vid = Get.parameters["vid"],
      type = Get.parameters["type"],
      section = Get.parameters["section"],
      seek = Get.parameters["seek"],
      episodeID = Get.parameters["episodeID"];

  int adsShown = 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  AdsService adsService = Get.find();

  RxList products = [].obs;
  Map productFadeTime = {}.obs;

  int recordingStartedFrom = 0;

  Map recordDuration = {"freemium": 15, "freemium+": 30, "premium": 90};

  late FlickManager flickManager;
  late FlickManager flickAdsManager;
  GlobalKey settingsKey = GlobalKey();
  RxString title = "Loading...".obs;
  RxBool loading = true.obs;

  bool seeked = false, pauseAds = false;
  OverlayEntry? overlayEntry;

  bool showPicker = false, isFullScreenSet = false;
  RxBool isFullscreen = false.obs,
      recordingStarted = false.obs,
      playingVideoAds = false.obs;
  late Timer timer, recordTimer;

  RxInt elapsedSeconds = 0.obs;
  RxBool downloading = false.obs;
  RxDouble progress = 0.0.obs;

  BottomTabController bottomTabController = Get.find();

  Future<bool> checkPermission() async {
    final permissionStatus = await Permission.storage.status;
    if (permissionStatus.isDenied) {
      await Permission.storage.request();
      if (permissionStatus.isDenied) {
        await Permission.storage.request();
        return false;
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      await Permission.storage.request();
      return false;
    }
    return true;
  }

  void startRecordingTimeout() {
    elapsedSeconds.value =
        recordDuration[bottomTabController.userData["accountType"]];

    recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (elapsedSeconds.value == 0) {
        recordTimer.cancel();
        stopRecording();
        return;
      }
      elapsedSeconds.value = elapsedSeconds.value - 1;
    });
  }

  Future<void> startRecording() async {
    NoScreenshot.instance.screenshotOn();
    try {
      String fileName = "vid_${DateTime.now().millisecondsSinceEpoch}";
      bool? started = await DeviceScreenRecorder.startRecordScreen(
        name: fileName,
        recordAudio: true,
      );
      // bool started = await FlutterScreenRecording.startRecordScreenAndAudio(fileName);
      if (started!) {
        recordingStarted.value = true;
        recordingStartedFrom = flickManager
            .flickVideoManager!
            .videoPlayerValue!
            .position
            .inMicroseconds;
        if (!flickManager.flickVideoManager!.videoPlayerValue!.isPlaying) {
          flickManager.flickControlManager!.play();
        }
        startRecordingTimeout();
      }
    } catch (e) {
      print(e);
      customSnackBar(text: e.toString());
    }
  }

  Future<void> stopRecording() async {
    pauseAds = false;
    recordingStarted.value = false;
    String? response = await DeviceScreenRecorder.stopRecordScreen();
    // String response = await FlutterScreenRecording.stopRecordScreen;
    if (response == null) return;
    flickManager.flickControlManager?.exitFullscreen();
    try {
      timer.cancel();
      recordTimer.cancel();
    } catch (e) {}
    NoScreenshot.instance.screenshotOff();
    Get.off(
      () => VideoEditor(
        file: response,
        vid: vid!,
        recordingStartedFrom: recordingStartedFrom,
      ),
    );
  }

  Future<void> showAds() async {
    if (bottomTabController.userData["accountType"] == "premium") return;

    String videoURL = await adsService.showCustomAds();

    if (videoURL.isEmpty) return;

    flickManager.flickControlManager!.pause();
    if (flickManager.flickControlManager!.isFullscreen) {
      isFullScreenSet = true;
      flickManager.flickControlManager!.exitFullscreen();
    } else {
      isFullScreenSet = false;
    }
    loadAdVideo(videoURL);

    Future.delayed(const Duration(minutes: 4), () {
      showAds();
    });
  }

  void loadAdVideo(String adURL) {
    playingVideoAds.value = true;
    flickAdsManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(adURL)),
      autoPlay: true,
      autoInitialize: true,
      onVideoEnd: () {
        if (flickAdsManager.flickControlManager!.isFullscreen) {
          flickAdsManager.flickControlManager!.exitFullscreen();
        }
        playingVideoAds.value = false;
        flickManager.flickControlManager!.play();
        if (isFullScreenSet) {
          flickManager.flickControlManager!.toggleFullscreen();
        }
        flickAdsManager.dispose();
      },
    );
    if (isFullScreenSet) {
      flickAdsManager.flickControlManager!.enterFullscreen();
    }
  }

  Future<void> loadVideo() async {
    DocumentSnapshot vdata = await videosCollection.doc(vid).get();

    String videoURL = "", subtitleURL = "";
    if (section == "movies") {
      title.value = vdata["title"];
      videoURL = vdata["video"];
      subtitleURL = vdata["subtitle"];
    } else {
      DocumentSnapshot epData = await videosCollection
          .doc(vid!)
          .collection("episodes")
          .doc(episodeID!)
          .get();
      title.value = "${vdata["title"]}: ${epData["episodeName"]}";
      videoURL = epData["video"];
      subtitleURL = epData["subtitle"];
    }
    int position = 0;

    if (seek != null) {
      position = int.parse(seek!);
    } else {
      DocumentSnapshot data = await usersCollection
          .doc(uid)
          .collection("continueWatching")
          .doc(section == "series" ? "${vid}_$episodeID" : vid!)
          .get();
      if (data.exists) {
        position = data["position"];
      }
    }

    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(videoURL),
        closedCaptionFile: loadCaptions(subtitleURL),
      ),
      autoPlay: false,
      autoInitialize: true,
      getPlayerControlsTimeout:
          ({
            bool? errorInVideo,
            bool? isPlaying,
            bool? isVideoEnded,
            bool? isVideoInitialized,
          }) {
            if (isVideoInitialized! && !seeked) {
              flickManager.flickControlManager!.seekForward(
                Duration(microseconds: position),
              );
              seeked = true;
              // flickManager.flickControlManager!.toggleFullscreen();
            }
            return const Duration(seconds: 3);
          },
    );

    loading.value = false;
    showAds();

    flickManager.flickVideoManager!.addListener(() async {
      int elapsedSeconds =
          flickManager.flickVideoManager!.videoPlayerValue!.position.inSeconds;

      isFullscreen.value = flickManager.flickControlManager!.isFullscreen;

      if (elapsedSeconds > 0) {
        if (productFadeTime.isNotEmpty) {
          productFadeTime.forEach((key, value) {
            if (elapsedSeconds > value) {
              products.remove(key);
              productFadeTime.remove(key);
            }
          });
        }

        await videosCollection
            .doc(vid)
            .collection("products")
            .where("startAt", isEqualTo: elapsedSeconds)
            .get()
            .then((value) {
              for (var doc in value.docs) {
                if (!products.contains(doc.id)) {
                  productFadeTime[doc.id] = elapsedSeconds + doc["displayFor"];
                  products.add(doc.id);
                }
              }

              products.value = products.toSet().toList();
            });
      }
    });

    Future.delayed(const Duration(minutes: 3), () {
      watchCounter(vid!, uid!);
    });
  }

  Future<ClosedCaptionFile> loadCaptions(String subtitleURL) async {
    final url = Uri.parse(subtitleURL);
    try {
      final data = await http.get(url);
      final srtContent = data.body.toString().replaceAll("ï»¿", "");

      flickManager.flickControlManager!.showSubtitle();
      return SubRipCaptionFile(srtContent);
    } catch (e) {
      return SubRipCaptionFile('');
    }
  }

  @override
  void onInit() {
    loadVideo();
    WidgetsBinding.instance.addObserver(this);

    super.onInit();
  }

  void watchCounter(String vid, String uid) async {
    await videoDataCollection.doc(vid).get().then((value) {
      if (!value["views"].contains(uid)) {
        videoDataCollection.doc(vid).update({
          "views": FieldValue.arrayUnion([uid]),
        });
        videosCollection.doc(vid).update({"views": FieldValue.increment(1)});
      }
    });
  }

  Future<void> onWillPop() async {
    flickManager.flickControlManager!.pause();
    Get.find<BottomTabController>().updateContinueWatching(
      position: flickManager
          .flickVideoManager!
          .videoPlayerValue!
          .position
          .inMicroseconds,
      duration: flickManager
          .flickVideoManager!
          .videoPlayerValue!
          .duration
          .inMicroseconds,
      vid: vid!,
      section: section!,
      type: type!,
      adsCount: adsShown,
      episodeID: episodeID!,
    );
  }

  @override
  void onReady() async {
    await videosCollection.doc(vid!).update({
      "trending": FieldValue.increment(1),
    });
    super.onReady();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        Get.find<BottomTabController>().updateContinueWatching(
          position: flickManager
              .flickVideoManager!
              .videoPlayerValue!
              .position
              .inMicroseconds,
          duration: flickManager
              .flickVideoManager!
              .videoPlayerValue!
              .duration
              .inMicroseconds,
          vid: vid!,
          section: section!,
          adsCount: adsShown,
          type: type!,
          episodeID: episodeID!,
        );
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    flickManager.dispose();
    NoScreenshot.instance.screenshotOff();
    try {
      timer.cancel();
      recordTimer.cancel();
      flickAdsManager.dispose();
    } catch (e) {}
    super.onClose();
  }
}
