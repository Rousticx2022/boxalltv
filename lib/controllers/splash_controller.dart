import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/views/maintenance.dart';
import 'package:video_player/video_player.dart';

import '../services/user_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  String uid = "";

  late VideoPlayerController videoPlayerController;
  RxBool loaded = false.obs;
  final box = GetStorage();

  Future<void> verifyAuthentication() async {
    uid = await UserService.instance.authenticate();

    DocumentSnapshot generalDoc =
        await generalCollection.doc("RCVdTHFlVIVCUjuiD1pm").get();

    update();
    Future.delayed(const Duration(milliseconds: 6000), () {
      if (uid.isEmpty) {
        Get.offAllNamed("/login");
        return;
      }

      if (!generalDoc["isLive"] || !generalDoc["isUnderMaintenance"]) {
        Get.offAll(() => Maintenance(
            isLive: generalDoc["isLive"],
            isUnderMaintenance: generalDoc["isUnderMaintenance"]));
        return;
      }

      Get.offAllNamed("/bottom_tab", parameters: {"uid": uid});
    });
  }

  @override
  void onInit() {
    videoPlayerController = VideoPlayerController.asset('assets/splash.mp4')
      ..initialize().then(
        (_) {
          videoPlayerController.setVolume(0.0);
          videoPlayerController.setPlaybackSpeed(1.5);
          videoPlayerController.play();

          loaded.value = true;
        },
      );
    verifyAuthentication();
    super.onInit();
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    super.onClose();
  }
}
