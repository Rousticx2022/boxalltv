import '../../services/reels_service.dart';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/services/upload_service.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:boxalltv/views/reels/create_reel.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:remixicon/remixicon.dart';
import '../../controllers/bottomtab_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../widgets/reel_video.dart';
import '../menu.dart';

// bool showReelAd = false;
// int showReelAfter = 0;

class ReelsTab extends StatefulWidget {
  final String uid;
  const ReelsTab({super.key, required this.uid});

  @override
  State<ReelsTab> createState() => _ReelsTabState();
}

class _ReelsTabState extends State<ReelsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kReelsPrimaryColor,
        title: GestureDetector(
          onTap: () =>
              Get.offAllNamed("/bottom_tab", parameters: {"uid": widget.uid}),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kBlackColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset("assets/logo.png", height: kToolbarHeight - 16),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kBlackColor,
            ),
            child: GetX<UploadService>(
              builder: (uploadService) {
                return uploadService.isReelUploading.value
                    ? SizedBox(
                        width: 45,
                        height: 45,
                        child: customCircularProgress(
                          strokeColor: kWhiteColor,
                          strokeWidth: 5,
                        ),
                      )
                    : IconButton(
                        onPressed: () async {
                          await availableCameras();
                          // Get.find<BottomTabController>().selectedIndex.value = 0;
                          Get.to(() => const CreateReel());
                        },
                        icon: const Icon(Remix.add_circle_fill),
                        color: kWhiteColor,
                      );
              },
            ),
          ),
          GestureDetector(
            onTap: () =>
                Get.toNamed("/notifications", parameters: {"uid": widget.uid}),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kBlackColor,
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: GetX<BottomTabController>(
                builder: (btController) {
                  return btController.unreadNotifications.value == 0
                      ? const Icon(Remix.notification_2_line)
                      : badges.Badge(
                          position: badges.BadgePosition.topEnd(
                            top: -10,
                            end: -4,
                          ),
                          badgeStyle: badges.BadgeStyle(
                            shape: badges.BadgeShape.circle,
                            badgeColor: kStreamPrimaryColor,
                            padding: const EdgeInsets.all(5),
                            borderRadius: BorderRadius.circular(20),
                            elevation: 0,
                          ),
                          badgeContent: Text(
                            btController.unreadNotifications.toString(),
                            style: fontButton(fontSize: 12),
                          ),
                          child: const Icon(Remix.notification_2_line),
                        );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kBlackColor,
            ),
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () => Get.to(
                () => Menu(uid: widget.uid),
                transition: Transition.cupertino,
              ),
              icon: const Icon(Remix.menu_3_line),
              color: kWhiteColor,
            ),
          ),
        ],
      ),
      body: FirestoreQueryBuilder(
        pageSize: 2,
        query: ReelsService().getActiveReelsQuery(),
        builder:
            (
              BuildContext context,
              FirestoreQueryBuilderSnapshot<dynamic> snapshot,
              Widget? child,
            ) {
              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.docs.length,
                pageSnapping: true,
                itemBuilder: (context, index) {
                  if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                    snapshot.fetchMore();
                  }

                  return SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: ReelVideo(
                      reelData: snapshot.docs[index],
                      uid: FirebaseAuth.instance.currentUser!.uid,
                      showAd: index % 10 == 0,
                    ),
                  );
                },
              );
            },
      ),
    );
  }
}
