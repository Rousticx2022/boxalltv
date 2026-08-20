import '../services/reels_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:numeral/numeral.dart';
import 'package:readmore/readmore.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/bottomtab_controller.dart';
import '../../services/ads_service.dart';
import '../../services/content_service.dart';
import '../../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/report_sheets.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'reel_video_ext3.dart';

part 'reel_video_ext.dart';

class ReelVideo extends StatefulWidget {
  final DocumentSnapshot reelData;
  final String uid;
  final bool showAd;

  const ReelVideo(
      {super.key,
      required this.reelData,
      required this.uid,
      required this.showAd});

  @override
  State<ReelVideo> createState() => _ReelVideoState();
}

class _ReelVideoState extends State<ReelVideo> with RouteAware {
  late VideoPlayerController videoPlayerController;
  // final audioPlayer = AudioPlayer();
  bool isPlaying = false, followButtonLoading = false;
  final TextEditingController commentController = TextEditingController();
  BottomTabController bottomTabController = Get.find();
  AdsService adsService = Get.find();

  Future<void> toggleReelLike(bool liked) async {
    if (widget.uid.isEmpty) {
      return;
    }
    if (liked) {
      await ReelsService().unlikeReel(widget.reelData.id, widget.uid);
      widget.reelData.reference.update({"likes": FieldValue.increment(-1)});
    } else {
      await ReelsService().likeReel(widget.reelData.id, widget.uid);
      widget.reelData.reference.update({"likes": FieldValue.increment(1)});
    }
  }

  Future<void> sendComment() async {
    if (commentController.text.trim().isEmpty) {
      return;
    }

    await ReelsService()
        .addComment(widget.reelData.id, commentController.text, widget.uid);
    commentController.clear();
    widget.reelData.reference.update({"comments": FieldValue.increment(1)});
  }

  void reportComment(DocumentReference documentReference) {
    Get.defaultDialog(
        title: "Report Comment",
        backgroundColor: Colors.grey.shade900,
        titleStyle: fontBody(
            fontSize: 20, color: kWhiteColor, fontWeight: FontWeight.bold),
        content: Text("This comment will be reviewed by us withing 24 hours",
            textAlign: TextAlign.center,
            style: fontBody(
                fontSize: 16, color: kWhiteColor, fontWeight: FontWeight.w500)),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlackColor,
              foregroundColor: kWhiteColor,
              elevation: 0,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            ),
            child: Text("No",
                style: fontBody(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              documentReference.update({
                "active": false,
                "deactivateReason": "UserReport",
              });
              Get.back();
              customSnackBar(text: "Reported successfully");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kReelsPrimaryColor,
              foregroundColor: kBlackColor,
              elevation: 0,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            ),
            child: Text("Report",
                style: fontBody(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ]);
  }

  void deleteReel(DocumentReference docRef) {
    Get.defaultDialog(
        title: "Delete Reel",
        titleStyle: fontHeading(
            fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
        content: Text(
          "Are you sure you want to delete this reel?",
          style: fontBody(),
          textAlign: TextAlign.center,
        ),
        barrierDismissible: false,
        backgroundColor: kGreyColor2,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: kGreyColor1,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Close",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
          TextButton(
            onPressed: () {
              docRef.delete();
              customSnackBar(text: "Reel deleted");
              Get.find<AdsService>().showRewardedAd(1);
            },
            style: TextButton.styleFrom(
              backgroundColor: kButtonColor,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Delete",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        ]);
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    commentController.dispose();
    // audioPlayer.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return buildMain(context);
  }
}
