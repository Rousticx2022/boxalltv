import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:boxalltv/services/user_service.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:boxalltv/views/product_details.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../controllers/watch_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:badges/badges.dart' as badges;

part 'watch_ext3.dart';

class Watch extends GetView<WatchController> {
  const Watch({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return buildMain(context);
  }

  customAdsControls(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        const Positioned.fill(child: FlickShowControlsAction()),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: kWhiteColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child:
                        Text("Playing ad", style: fontBody(color: kWhiteColor)),
                  ),
                  Row(
                    children: <Widget>[
                      Row(
                        children: [
                          FlickCurrentPosition(fontSize: 15.sp),
                          const Text(' / ',
                              style:
                                  TextStyle(color: kWhiteColor, fontSize: 12)),
                          FlickTotalDuration(fontSize: 15.sp),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      FlickSoundToggle(
                        size: 20.sp,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 20),
                      FlickFullScreenToggle(
                        size: 20.sp,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  customControlsMobile(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: FlickAutoHideChild(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                        child: FlickPlayToggle(size: 20.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: [
                          FlickCurrentPosition(fontSize: 13.sp),
                          const Text(' / ',
                              style:
                                  TextStyle(color: kWhiteColor, fontSize: 12)),
                          FlickTotalDuration(fontSize: 13.sp),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      FlickSubtitleToggle(
                        size: 17.sp,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 20),
                      FlickSoundToggle(
                        size: 17.sp,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 20),
                      FlickFullScreenToggle(
                        size: 17.sp,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 5,
                      handleRadius: 8,
                      curveRadius: 50,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      playedColor: kPrimaryColor,
                      handleColor: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  customControls(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: FlickAutoHideChild(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                        child: FlickPlayToggle(size: 30.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                          child: Obx(() => Text(controller.title.value,
                              style: GoogleFonts.montserrat(
                                  fontSize: 18.sp, color: kWhiteColor)))),
                      Obx(
                        () => controller.isFullscreen.value
                            ? TextButton.icon(
                                onPressed: () {
                                  if (controller.recordingStarted.value) {
                                    controller.stopRecording();
                                  } else {
                                    controller.startRecording();
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: kBlackColor,
                                  backgroundColor: kWhiteColor.withValues(alpha: 0.7),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: Icon(
                                    controller.recordingStarted.value
                                        ? Icons.stop_circle
                                        : Icons.circle_rounded,
                                    color: Colors.red,
                                    size: 15.sp),
                                label: Text(
                                    controller.recordingStarted.value
                                        ? "${controller.elapsedSeconds.value}s"
                                        : "Record Clip",
                                    style: fontButton(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500)),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: [
                          FlickCurrentPosition(fontSize: 15.sp),
                          const Text(' / ',
                              style:
                                  TextStyle(color: kWhiteColor, fontSize: 12)),
                          FlickTotalDuration(fontSize: 15.sp),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      FlickSubtitleToggle(
                        size: 20.sp,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 20),
                      FlickSoundToggle(
                        size: 20.sp,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 20),
                      FlickFullScreenToggle(
                        size: 20.sp,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: kWhiteColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 10,
                      handleRadius: 10,
                      curveRadius: 50,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      playedColor: kPrimaryColor,
                      handleColor: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
