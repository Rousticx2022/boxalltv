import 'dart:async';
import 'dart:io';
import 'package:animated_music_indicator/animated_music_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/views/reels/upload_video.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';
import 'package:http/http.dart' as http;

class VideoRecorderController extends GetxController
    with WidgetsBindingObserver {
  String? uid = Get.parameters["uid"];
  late List<CameraDescription> cameras;
  late CameraController cameraController;

  RxInt cameraDirection = 1.obs;
  RxDouble recordingProgress = 0.0.obs;
  RxBool cameraInitialized = false.obs,
      isRecording = false.obs,
      isPaused = false.obs,
      isFlashing = false.obs,
      soundSelected = false.obs;

  RxMap selectedSound = {}.obs;

  RxInt currentRecodingMode = 15.obs;
  RxList recordingModes = [15, 30, 60, 90].obs;
  late Timer timer;

  final player = AudioPlayer();

  selectSound() async {
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(top: kToolbarHeight * 3),
          decoration: const BoxDecoration(
            color: kBlackColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                leading: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kReelsPrimaryColor.withValues(alpha: 0.2),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (player.playing) {
                        await player.stop();
                      }
                      Get.back();
                    },
                    icon: const Icon(Remix.close_line),
                    constraints:
                        const BoxConstraints(maxHeight: 35, maxWidth: 35),
                    padding: const EdgeInsets.all(5),
                    color: kWhiteColor,
                  ),
                ),
                title: Text("Pick a sound",
                    style: fontHeading(
                        fontSize: 18.sp,
                        color: kReelsPrimaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: FirestoreListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  query:
                      reelSoundsCollection.orderBy("addedAt", descending: true),
                  emptyBuilder: (context) =>
                      const Center(child: Text("No sound found")),
                  itemBuilder: (context, soundData) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: kWhiteColor.withValues(alpha: 0.1),
                      ),
                      child: ListTile(
                          minLeadingWidth: 0,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: soundData["thumbnail"],
                              placeholder: (context, s) =>
                                  const ColoredBox(color: kGreyColor2),
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text("${soundData["title"]}",
                              style: fontHeading(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            "${soundData["author"]} - ${soundData["duration"]}",
                            style:
                                fontBody(color: kWhiteColor, fontSize: 14.sp),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (selectedSound["id"] != soundData.id) {
                                    if (player.playing) {
                                      await player.stop();
                                    }
                                    await player.setUrl(soundData["url"]);
                                    player.play();
                                    selectedSound["id"] = soundData.id;
                                    selectedSound["title"] = soundData["title"];
                                    selectedSound["url"] = soundData["url"];

                                    return;
                                  }
                                  selectedSound["id"] = "";
                                  await player.stop();
                                },
                                constraints: const BoxConstraints(maxWidth: 30),
                                icon: Obx(
                                  () => selectedSound["id"] == soundData.id &&
                                          !soundSelected.value
                                      ? AnimatedMusicIndicator(
                                          animate: true,
                                          numberOfBars: 4,
                                          size: 0.30,
                                          backgroundColor: Colors.transparent,
                                          barStyle: BarStyle.dash,
                                          roundBars: true,
                                          colors: const [
                                            kButtonColor,
                                            kWhiteColor,
                                            kButtonColor,
                                            kWhiteColor,
                                          ],
                                        )
                                      : const Icon(Remix.disc_line,
                                          size: 18, color: kButtonColor),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () async {
                                  selectedSound.value = {
                                    "id": soundData.id,
                                    "url": soundData["url"],
                                    "title": soundData["title"],
                                    "thumbnail": soundData["thumbnail"],
                                  };
                                  soundSelected.value = true;
                                  if (player.playing) {
                                    player.stop();
                                  }
                                  Get.back();
                                },
                                constraints: const BoxConstraints(maxWidth: 30),
                                icon: const Icon(Remix.arrow_right_circle_fill,
                                    size: 18, color: kButtonColor),
                              ),
                            ],
                          )),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<String> getAudioFilePath(
      {required String fileName, required String url}) async {
    var response = await http.get(Uri.parse(selectedSound["url"]));
    final cacheDirectory = (await getExternalStorageDirectory())!.path;
    File audioFile = File('$cacheDirectory/$fileName.mp3');
    audioFile.writeAsBytesSync(response.bodyBytes);
    return audioFile.path;
  }

  toggleFlash() async {
    if (cameraDirection.value == 1) {
      // customSnackBar(text: "Flash not supported on front camera");
      return;
    }
    if (cameraController.value.flashMode == FlashMode.off) {
      isFlashing.value = true;
      cameraController.setFlashMode(FlashMode.torch);
    } else {
      isFlashing.value = false;
      cameraController.setFlashMode(FlashMode.off);
    }
  }

  toggleRecordingMode() {
    switch (currentRecodingMode.value) {
      case 15:
        currentRecodingMode.value = 30;
        break;
      case 30:
        currentRecodingMode.value = 60;
        break;
      case 60:
        currentRecodingMode.value = 90;
        break;
      case 90:
        currentRecodingMode.value = 15;
        break;
    }
  }

  pauseRecording() async {
    timer.cancel();
    await cameraController.pauseVideoRecording();
    if (soundSelected.value && player.playing) await player.pause();
    isRecording.value = false;
    isPaused.value = true;
  }

  resumeRecording() async {
    isRecording.value = true;
    isPaused.value = false;
    if (soundSelected.value) await player.play();
    await cameraController.resumeVideoRecording();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingProgress.value += 1;
      if (recordingProgress.value == currentRecodingMode.value) {
        stopRecording();
      }
    });
  }

  startRecording() async {
    isRecording.value = true;
    isPaused.value = false;
    if (soundSelected.value) {
      await player.setUrl(selectedSound["url"]);
      player.play();
      await cameraController.startVideoRecording();
    } else {
      await cameraController.startVideoRecording();
    }

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingProgress.value += 1;
      if (recordingProgress.value == currentRecodingMode.value) {
        stopRecording();
      }
    });
  }

  stopRecording() async {
    timer.cancel();
    XFile videoFile = await cameraController.stopVideoRecording();
    if (soundSelected.value && player.playing) await player.stop();
    isRecording.value = false;
    recordingProgress.value = 0.0;
    timer.cancel();

    if (videoFile.path.isEmpty) {
      return;
    }
    toggleFlash();
    cameraController.pausePreview();

    Get.back();

    Get.to(() => UploadVideo(
        uid: uid!, videoPath: videoFile.path, soundData: selectedSound));
  }

  initializeCameraController(int camDir) async {
    cameras = await availableCameras();

    if (isRecording.value) {
      stopRecording();
    }

    cameraController = CameraController(
      cameras[camDir],
      ResolutionPreset.max,
      enableAudio: true,
    );
    cameraController.initialize().then((_) {
      cameraDirection.value = camDir;
      cameraInitialized.value = true;
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void onInit() async {
    initializeCameraController(cameraDirection.value);
    WidgetsBinding.instance.addObserver(this);
    selectedSound.value = {
      "url": "",
      "id": "",
      "title": "",
      "thumbnail": "",
    };

    super.onInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraInitialized.value = false;
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCameraController(cameraDirection.value);
    }
  }

  @override
  void onClose() {
    cameraController.removeListener(() {});
    cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    try {
      if (timer.isActive) {
        timer.cancel();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    super.onClose();
  }
}
