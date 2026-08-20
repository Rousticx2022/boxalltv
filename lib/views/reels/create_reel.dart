import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remixicon/remixicon.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/styles.dart';
import 'add_reel_details.dart';

part 'create_reel_ext3.dart';

part 'create_reel_ext.dart';

class CreateReel extends StatefulWidget {
  const CreateReel({super.key});

  @override
  State<CreateReel> createState() => _CreateReelState();
}

class _CreateReelState extends State<CreateReel> with WidgetsBindingObserver {
  late CameraController cameraController;

  bool _captureAudioInVideoRecording = true,
      _isVideoRecording = false,
      _isVideoRecorded = false;
  bool _isFacingFront = true;
  double _zoom = 1.0, maxZoom = 5.0;
  bool _enableFlashlight = false, _isCameraReady = false;

  int cameraDirection = 1, selectedRecordTimer = 15;
  int recordingProgress = 0;
  List recordingTimers = [15, 30, 60, 90];
  late Timer timer;
  RxMap selectedSound = {}.obs;

  List cameras = [];

  ImagePicker imagePicker = ImagePicker();

  pickVideo() async {
    final pickedFile = await imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      Get.to(() =>
          AddReelDetails(videoPath: pickedFile.path, audioData: selectedSound));
    }
  }

  Future<String> generateFilePath(String prefix, String fileExt) async {
    final filename = '$prefix${DateTime.now().millisecondsSinceEpoch}$fileExt';
    return '/storage/emulated/0/Download/${Platform.pathSeparator}$filename';
  }

  initializeCamera(int cameraDirection) async {
    cameras = await availableCameras();
    cameraController = CameraController(
        cameras[cameraDirection], ResolutionPreset.max,
        enableAudio: _captureAudioInVideoRecording);
    cameraController.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      maxZoom = await cameraController.getMaxZoomLevel();

      setState(() {
        _isCameraReady = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            Permission.camera.request();
            Get.back();
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  toggleCamDirection() {
    _isFacingFront = !_isFacingFront;
    cameraDirection = _isFacingFront ? 1 : 0;
    // cameraController.dispose();
    initializeCamera(cameraDirection);
    setState(() {});
  }

  enableFlash() {
    _enableFlashlight = !_enableFlashlight;
    cameraController
        .setFlashMode(_enableFlashlight ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  startRecording() async {
    setState(() {
      _isVideoRecording = true;
    });
    cameraController.startVideoRecording();

    int cutoutTime = selectedRecordTimer * 1000;

    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        recordingProgress += 10;
      });
      if (recordingProgress == cutoutTime) {
        setState(() {
          _isVideoRecorded = true;
        });
        stopRecording();
      }
    });
  }

  stopRecording() async {
    timer.cancel();
    debugPrint('CameraPage: stopVideoRecording');

    XFile xFile = await cameraController.stopVideoRecording();

    Get.off(
        () => AddReelDetails(videoPath: xFile.path, audioData: selectedSound));
  }

  toggleRecordingMode() {
    switch (selectedRecordTimer) {
      case 15:
        setState(() {
          selectedRecordTimer = 30;
        });
        break;
      case 30:
        setState(() {
          selectedRecordTimer = 60;
        });
        break;
      case 60:
        setState(() {
          selectedRecordTimer = 90;
        });
      case 90:
        setState(() {
          selectedRecordTimer = 15;
        });
        break;
    }
  }

  @override
  void initState() {
    initializeCamera(cameraDirection);
    WidgetsBinding.instance.addObserver(this);
    // Get.find<AdsService>().showRewardedAd();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        Get.back();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    cameraController.removeListener(() {});
    cameraController.dispose();

    try {
      if (timer.isActive) {
        timer.cancel();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return buildMain(context);
  }
}
