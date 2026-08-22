import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:boxalltv/views/menu.dart';
import 'package:boxalltv/views/social/chats_tab.dart';
import 'package:boxalltv/views/social/feed_tab.dart';
import 'package:boxalltv/views/social/social_search_tab.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/bottomtab_controller.dart';
import '../../controllers/upload_controller.dart';
import '../../services/ads_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../social/friends_tab.dart';

class SocialsTab extends StatefulWidget {
  final String uid;
  const SocialsTab({super.key, required this.uid});

  @override
  State<SocialsTab> createState() => _SocialsTabState();
}

class _SocialsTabState extends State<SocialsTab>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int tabIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSocialPrimaryColor,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            width: context.width,
            color: const Color(0xff161820),
            child: TabBar(
              controller: tabController,
              indicatorColor: kSocialPrimaryColor,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: kSocialPrimaryColor),
              ),
              indicatorWeight: 4,
              labelColor: kSocialPrimaryColor,
              unselectedLabelColor: kWhiteColor.withValues(alpha: 0.7),
              labelStyle: fontBody(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: "Feed"),
                Tab(text: "Chats"),
                Tab(text: "Search"),
                Tab(text: "Friends"),
              ],
            ),
          ),
        ),
        actions: [
          GetX<UploadController>(
            builder: (uploadController) {
              return GestureDetector(
                onTap: uploadController.isUploadingPost.value
                    ? () {}
                    : () {
                        Get.find<AdsService>().showRewardedAd(1);
                        Get.toNamed(
                          "/create_post",
                          parameters: {"uid": widget.uid},
                        );
                      },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kBlackColor,
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  child: uploadController.isUploadingPost.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: customCircularProgress(
                            strokeColor: kWhiteColor,
                          ),
                        )
                      : const Icon(Icons.add),
                ),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              if (Get.find<AdsService>().showRewardedAd(1)) {
                Get.toNamed("/notifications", parameters: {"uid": widget.uid});
              } else {
                Get.toNamed("/notifications", parameters: {"uid": widget.uid});
              }
            },
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
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          FeedTab(uid: widget.uid),
          ChatTab(uid: widget.uid),
          SocialSearchTab(uid: widget.uid),
          FriendsTab(uid: widget.uid),
        ],
      ),
    );
  }
}
