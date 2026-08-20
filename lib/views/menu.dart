import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/views/saved_videos.dart';
import 'package:boxalltv/views/track_orders.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../services/ads_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_service.dart';
import 'advertisers/become_an_advertiser.dart';
import 'channel/become_a_creator.dart';
import 'edit_user_profile.dart';
import 'subscriptions.dart';

part 'menu_ext3.dart';

class Menu extends StatefulWidget {
  final String uid;
  const Menu({super.key, required this.uid});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool channelLoading = false, advertisersLoading = false;

  void showCreatorAccountBlocked() {
    Get.defaultDialog(
        title: "Account Blocked",
        titleStyle: fontHeading(
            fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
        content: Text(
          "Please contact support if you want to reactivate your account",
          style: fontBody(),
          textAlign: TextAlign.center,
        ),
        barrierDismissible: false,
        backgroundColor: kGreyColor2,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: kButtonColor,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Close",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        ]);
  }

  void showAdvertiserAccountBlocked() {
    Get.defaultDialog(
        title: "Account Blocked",
        titleStyle: fontHeading(
            fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
        content: Text(
          "Please contact support if you want to reactivate your account",
          style: fontBody(),
          textAlign: TextAlign.center,
        ),
        barrierDismissible: false,
        backgroundColor: kGreyColor2,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: kButtonColor,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Close",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        ]);
  }

  void showCreatorAccountPending() {
    Get.defaultDialog(
        title: "Pending Approval",
        titleStyle: fontHeading(
            fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
        content: Text(
          "Your request to become a creator is still under review. Please be patient, it may take up to 3-4 business days",
          style: fontBody(),
          textAlign: TextAlign.center,
        ),
        barrierDismissible: false,
        backgroundColor: kGreyColor2,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: kButtonColor,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Close",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        ]);
  }

  void showAdvertiserAccountPending() {
    Get.defaultDialog(
        title: "Pending Approval",
        titleStyle: fontHeading(
            fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
        content: Text(
          "Your request to become a advertiser is still under review. Please be patient, it may take up to 3-4 business days",
          style: fontBody(),
          textAlign: TextAlign.center,
        ),
        barrierDismissible: false,
        backgroundColor: kGreyColor2,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: kButtonColor,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Close",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        ]);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return buildMain(context);
  }
}
