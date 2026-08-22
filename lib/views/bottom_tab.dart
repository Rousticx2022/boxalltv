import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/bottomtab_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:cnav/cnav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../utils/styles.dart';

class BottomTab extends GetView<BottomTabController> {
  const BottomTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.tabs[controller.selectedIndex.value]),
      floatingActionButton: context.mediaQueryViewInsets.bottom == 0
          ? null
          : FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              backgroundColor: kStreamPrimaryColor,
              child: const Icon(
                Icons.keyboard_hide_rounded,
                color: kWhiteColor,
              ),
            ),
      bottomNavigationBar: Obx(
        () => CNav(
          iconSize: 16.sp,
          backgroundColor: Colors.black,
          selectedColor: kPrimaryColor,
          strokeColor: kWhiteColor.withValues(alpha: 0.4),
          items: [
            CNavItem(
              icon: const Icon(Remix.movie_2_line),
              selectedIcon: const Icon(
                Remix.movie_2_fill,
                color: kStreamPrimaryColor,
              ),
              title: Text(
                "Stream",
                style: customTextStyleBody(
                  fontSize: 13.sp,
                  color: kStreamPrimaryColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            CNavItem(
              icon: const Icon(Remix.compass_discover_line),
              selectedIcon: const Icon(
                Remix.compass_discover_fill,
                color: kSocialPrimaryColor,
              ),
              title: Text(
                "Social",
                style: customTextStyleBody(
                  fontSize: 13.sp,
                  color: kSocialPrimaryColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            CNavItem(
              icon: const Icon(Remix.film_line),
              selectedIcon: const Icon(
                Remix.film_fill,
                color: kReelsPrimaryColor,
              ),
              title: Text(
                "Reels",
                style: customTextStyleBody(
                  fontSize: 13.sp,
                  color: kReelsPrimaryColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            CNavItem(
              icon: const Icon(Remix.music_2_line),
              selectedIcon: const Icon(
                Remix.music_2_fill,
                color: kMusicPrimaryColor,
              ),
              title: Text(
                "Music",
                style: customTextStyleBody(
                  fontSize: 13.sp,
                  color: kMusicPrimaryColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            controller.selectedIndex.value = index;
          },
        ),
      ),
    );
  }
}
