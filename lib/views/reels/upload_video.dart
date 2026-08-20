import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:animated_music_indicator/animated_music_indicator.dart';
import 'package:easy_audio_trimmer/easy_audio_trimmer.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../utils/collections.dart';

part 'upload_video_ext.dart';

class UploadVideo extends StatefulWidget {
  final String uid, videoPath;
  final Map soundData;
  const UploadVideo(
      {super.key,
      required this.uid,
      required this.videoPath,
      required this.soundData});

  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  late VideoPlayerController videoPlayerController;
  final player = AudioPlayer();
  Map selectedSound = {};
  int currentPage = 1;
  String thumbnailImagePath = "";
  bool isTyping = false, videoPaused = false, soundSelected = false;
  TextEditingController captionController = TextEditingController();
  final Trimmer audioTrimmer = Trimmer();
  PageController pageController = PageController();

  Future<String> _getAudioFilePath(fileName) async {
    var response = await http.get(Uri.parse(selectedSound["url"]));
    final cacheDirectory = (await getExternalStorageDirectory())!.path;
    File audioFile = File('$cacheDirectory/$fileName.mp3');
    audioFile.writeAsBytesSync(response.bodyBytes);
    return audioFile.path;
  }

  // Future<String> _getOutputFilePath(fileName) async {
  //   final directory = await getExternalStorageDirectory();
  //   return '${directory!.path}/reel_$fileName.mp4';
  // }

  // Future<String> _getOutputAudioFilePath(fileName) async {
  //   final directory = await getExternalStorageDirectory();
  //   return '${directory!.path}/trimmed_$fileName.mp3';
  // }

  createReel(
      {required String fileName,
      required String videoPath,
      String audioPath = ""}) async {
    // final storageRef = FirebaseStorage.instance.ref();
    String videoURL = '', thumbnailURL = '', audioURL = '';

    // try {
    FTPConnect ftpConnect = FTPConnect("storage.bunnycdn.com",
        user: const String.fromEnvironment('FTP_USER'),
        pass: const String.fromEnvironment('FTP_PASS'));

    await ftpConnect.connect();
    await ftpConnect.changeDirectory("reels");
    await ftpConnect.createFolderIfNotExist(widget.uid);
    await ftpConnect.changeDirectory(widget.uid).then((value) async {
      bool videoStatus = await ftpConnect.uploadFileWithRetry(File(videoPath),
          pRetryCount: 3, pRemoteName: "reel_$fileName.mp4");
      if (videoStatus) {
        videoURL =
            "https://frametv.b-cdn.net/reels/${widget.uid}/reel_$fileName.mp4";
      }
      bool thumbStatus = await ftpConnect.uploadFileWithRetry(
          File(thumbnailImagePath),
          pRetryCount: 3,
          pRemoteName: "thumbnail_$fileName.webp");
      if (thumbStatus) {
        thumbnailURL =
            "https://frametv.b-cdn.net/reels/${widget.uid}/thumbnail_$fileName.webp";
      }
      if (audioPath.isNotEmpty) {
        bool audioStatus = await ftpConnect.uploadFileWithRetry(File(audioPath),
            pRetryCount: 3, pRemoteName: "audio_$fileName.mp3");
        if (audioStatus) {
          audioURL =
              "https://frametv.b-cdn.net/reels/${widget.uid}/audio_$fileName.mp3";
        }
      }

      ftpConnect.disconnect();
    });
    // } catch (e) {
    //   Get.back();
    // }

    // try {
    //   final upload = storageRef.child("reels/${widget.uid}/reel_$fileName.mp4");
    //   await upload.putFile(File(videoPath));
    //   videoURL = await upload.getDownloadURL();
    // } on FirebaseException catch (e) {
    //   Get.back();
    //   customSnackBar(text: e.code);
    // }

    // try {
    //   final upload = storageRef.child("reels/${widget.uid}/thumbnail_$fileName.webp");
    //   await upload.putData(thumbnailImage!);
    //   thumbnailURL = await upload.getDownloadURL();
    // } on FirebaseException catch (e) {
    //   Get.back();
    //   customSnackBar(text: e.code);
    // }

    await reelsCollection.add({
      'userID': widget.uid,
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
      'totalShares': 0
    });
    Get.back();
    Get.back();
    customSnackBar(text: "Reel uploaded successfully!");
  }

  upload() async {
    await videoPlayerController.pause();
    Get.defaultDialog(
      backgroundColor: kGreyColor2,
      title: "Uploading reel...",
      titleStyle: fontHeading(
          fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
      content: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kReelsPrimaryColor),
          ],
        ),
      ),
      onWillPop: () => Future.value(false),
      barrierDismissible: false,
    );
    String videoPath = widget.videoPath;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    if (selectedSound["url"].isNotEmpty) {
      String audioPath = await _getAudioFilePath(fileName);
      // String outputPathVideo = await _getOutputFilePath(fileName);

      try {
        audioTrimmer.loadAudio(audioFile: File(audioPath));
        await audioTrimmer.saveTrimmedAudio(
            startValue: 0.0,
            endValue:
                videoPlayerController.value.duration.inSeconds.toDouble() *
                    1000,
            audioFileName: "trimmed_$fileName",
            onSave: (outputPath) {
              if (outputPath == null) {
                customSnackBar(text: "Cannot export audio");
                return;
              }

              createReel(
                  fileName: fileName,
                  videoPath: videoPath,
                  audioPath: outputPath);
            });
      } catch (e) {
        Get.back();
        debugPrint(e.toString());
      }
    } else {
      createReel(fileName: fileName, videoPath: videoPath);
    }
  }

  nextButton() {
    switch (currentPage) {
      case 1:
        setState(() {
          currentPage = 2;
        });
        pauseVideoPlay();
        pageController.nextPage(
            duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
        generateThumbnail();
        break;
      case 2:
        upload();
        break;
    }
  }

  generateThumbnail() async {
    String? thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: widget.videoPath,
      imageFormat: ImageFormat.WEBP,
      quality: 25,
    );
    setState(() {
      thumbnailImagePath = thumbnailPath!;
    });
  }

  checkTyping() {
    if (captionController.text.isEmpty) {
      isTyping = false;
      setState(() {});
    } else {
      isTyping = true;
      setState(() {});
    }
  }

  pauseVideoPlay() async {
    if (videoPlayerController.value.isPlaying) {
      if (soundSelected && player.playing) {
        player.pause();
      }
      videoPlayerController.pause();
    }
  }

  toggleVideoPlay() async {
    if (videoPlayerController.value.isPlaying) {
      if (soundSelected && player.playing) {
        player.pause();
      }
      videoPlayerController.pause();
    } else {
      if (soundSelected) {
        await player.setUrl(selectedSound["url"]);
        player.play();
      }
      videoPlayerController.play();
      setState(() {
        videoPaused = false;
      });
    }
  }

  @override
  void initState() {
    setState(() {
      selectedSound = widget.soundData;
    });
    videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      })
      ..play()
      ..setLooping(true);
    videoPlayerController.addListener(() {
      if (!videoPlayerController.value.isPlaying) {
        setState(() {
          videoPaused = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    captionController.dispose();
    videoPlayerController.removeListener(() {});
    videoPlayerController.dispose();
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          videoPlayerController.value.isInitialized
              ? Stack(
                  fit: StackFit.expand,
                  alignment: AlignmentDirectional.center,
                  children: [
                    GestureDetector(
                      onTap: () => toggleVideoPlay(),
                      child: Container(
                        height: context.height,
                        width: context.width,
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: AspectRatio(
                          aspectRatio: videoPlayerController.value.aspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                VideoPlayer(videoPlayerController),
                                if (videoPaused)
                                  Icon(
                                    Icons.play_circle,
                                    size: 32.sp,
                                    color: kWhiteColor,
                                    shadows: const [
                                      Shadow(color: kGreyColor1, blurRadius: 10)
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // top section
                    Positioned(
                      top: kToolbarHeight - 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.only(left: 20),
                              decoration: ShapeDecoration(
                                  shape: const CircleBorder(),
                                  color: kBlackColor.withValues(alpha: 0.4)),
                              child: Icon(Remix.close_line,
                                  color: kWhiteColor, size: 22.sp),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => selectSound(),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.only(right: 20),
                              decoration: ShapeDecoration(
                                  shape: const CircleBorder(),
                                  color: kBlackColor.withValues(alpha: 0.4)),
                              child: Icon(Remix.music_2_line,
                                  color: kWhiteColor, size: 22.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : customCircularProgress(strokeColor: kReelsPrimaryColor),
          ListView(
            padding: const EdgeInsets.symmetric(
                vertical: kToolbarHeight, horizontal: 20),
            children: [
              if (thumbnailImagePath.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(File(thumbnailImagePath),
                        width: context.width / 2.5),
                  ),
                ),
              const SizedBox(height: 30),
              TextFormField(
                controller: captionController,
                style: fontBody(fontSize: 17.sp),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter caption here...",
                  hintStyle: fontBody(fontSize: 17.sp),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              )
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentPage == 1) const SizedBox(),
              if (currentPage == 2)
                ElevatedButton.icon(
                  onPressed: () {
                    currentPage = 1;
                    pageController.previousPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeIn);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kReelsPrimaryColor.withValues(alpha: 0.3),
                    foregroundColor: kWhiteColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Remix.edit_circle_fill, size: 18.sp),
                  label: Text('Edit Video',
                      style: fontButton(
                          fontSize: 16.sp, fontWeight: FontWeight.w500)),
                ),
              ElevatedButton.icon(
                onPressed: () => nextButton(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kReelsPrimaryColor.withValues(alpha: 0.3),
                  foregroundColor: kWhiteColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: Text('Next',
                    style: fontButton(
                        fontSize: 16.sp, fontWeight: FontWeight.w500)),
                label: Icon(Remix.arrow_right_s_line, size: 18.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
