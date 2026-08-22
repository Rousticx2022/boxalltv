import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/controllers/video_recorder_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/styles.dart';

class VideoRecorder extends GetView<VideoRecorderController> {
  const VideoRecorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.center,
        children: [
          // preview
          Obx(
            () => controller.cameraInitialized.value
                ? SafeArea(
                    child: Container(
                      height: context.height,
                      width: context.width,
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: AspectRatio(
                        aspectRatio:
                            context.width /
                            controller
                                .cameraController
                                .value
                                .previewSize!
                                .height,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CameraPreview(controller.cameraController),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          // left section
          Positioned(
            left: 20,
            top: context.height / 3,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: "Switch Camera",
                    onPressed: () {
                      if (controller.isRecording.value) {
                        customSnackBar(
                          text: "Cannot switch camera while recording",
                        );
                        return;
                      }
                      controller.cameraInitialized.value = false;
                      controller.cameraController.dispose();
                      controller.initializeCameraController(
                        controller.cameraDirection.value == 0 ? 1 : 0,
                      );
                    },
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(
                      maxHeight: 35,
                      maxWidth: 35,
                    ),
                    icon: const Icon(
                      Remix.refresh_line,
                      color: kWhiteColor,
                      shadows: [Shadow(color: kGreyColor1, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    tooltip: "Music",
                    onPressed: () {
                      if (controller.soundSelected.value) {
                        controller.soundSelected.value = false;
                        controller.selectedSound.value = {
                          "url": "",
                          "id": "",
                          "title": "",
                        };
                        return;
                      }
                      controller.selectSound();
                    },
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(
                      maxHeight: 35,
                      maxWidth: 35,
                    ),
                    icon: const Icon(
                      Remix.music_2_line,
                      color: kWhiteColor,
                      shadows: [Shadow(color: kGreyColor1, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => controller.toggleRecordingMode(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Obx(
                        () => Text(
                          "${controller.currentRecodingMode.value}s",
                          style: fontButton(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 17.sp,
                            shadows: const [
                              Shadow(color: kGreyColor1, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // bottom section
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: context.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => {},
                    child: Container(
                      height: 15.w,
                      width: 15.w,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        color: kReelsPrimaryColor.withValues(alpha: 0.3),
                      ),
                      child: Icon(
                        Remix.image_2_fill,
                        color: kWhiteColor,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  Container(
                    height: 20.w,
                    width: 20.w,
                    color: Colors.transparent,
                    child: Obx(
                      () => Stack(
                        fit: StackFit.expand,
                        alignment: AlignmentDirectional.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 5,
                            color: kWhiteColor.withValues(alpha: 0.5),
                            value: 1,
                          ),
                          CircularProgressIndicator(
                            strokeWidth: 5,
                            color: kWhiteColor,
                            value:
                                (1 / controller.currentRecodingMode.value) *
                                controller.recordingProgress.value,
                            valueColor: const AlwaysStoppedAnimation(
                              kReelsPrimaryColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.isRecording.value
                                ? controller.pauseRecording()
                                : controller.isPaused.value
                                ? controller.resumeRecording()
                                : controller.startRecording(),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.isRecording.value
                                    ? kWhiteColor
                                    : kButtonColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => controller.isPaused.value
                        ? GestureDetector(
                            onTap: () => controller.stopRecording(),
                            child: Container(
                              height: 15.w,
                              width: 15.w,
                              padding: const EdgeInsets.all(10),
                              decoration: ShapeDecoration(
                                shape: const CircleBorder(),
                                color: kReelsPrimaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              child: Icon(
                                Remix.arrow_right_s_line,
                                color: kWhiteColor,
                                size: 20.sp,
                              ),
                            ),
                          )
                        : SizedBox(width: 15.w),
                  ),
                ],
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
                      color: kBlackColor.withValues(alpha: 0.4),
                    ),
                    child: Icon(
                      Remix.close_line,
                      color: kWhiteColor,
                      size: 22.sp,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleFlash(),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(right: 20),
                    decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: kBlackColor.withValues(alpha: 0.4),
                    ),
                    child: Obx(
                      () => controller.isFlashing.value
                          ? Icon(
                              Remix.flashlight_fill,
                              color: kWhiteColor,
                              size: 22.sp,
                            )
                          : Icon(
                              Remix.flashlight_line,
                              color: kWhiteColor,
                              size: 22.sp,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
