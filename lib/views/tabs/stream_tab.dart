import 'package:boxalltv/services/ads_service.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:boxalltv/views/stream/movies_tab.dart';
import 'package:boxalltv/views/stream/series_tab.dart';
import 'package:boxalltv/views/stream/upcoming_tab.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/bottomtab_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:remixicon/remixicon.dart';

import '../menu.dart';
import '../stream/all_tab.dart';
import '../stream/search_tab.dart';
import '../stream/watchlist_tab.dart';

class StreamTab extends StatefulWidget {
  final String uid;
  const StreamTab({super.key, required this.uid});

  @override
  State<StreamTab> createState() => _StreamTabState();
}

class _StreamTabState extends State<StreamTab>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int tabIndex = 1;
  List<String> titles = [
    "Search",
    "Home",
    "Films",
    "Tv Series",
    "Favourite",
    "Upcoming",
  ];
  @override
  void initState() {
    tabController = TabController(length: 6, initialIndex: 1, vsync: this);
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
        backgroundColor: kStreamPrimaryColor,
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
          GestureDetector(
            onTap: () => Get.toNamed("/cart", parameters: {"uid": widget.uid}),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kBlackColor,
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: GetX<BottomTabController>(builder: (btController) {
                return btController.unreadNotifications.value == 0
                    ? const Icon(Icons.shopping_cart_outlined)
                    : badges.Badge(
                        position:
                            badges.BadgePosition.topEnd(top: -10, end: -4),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: kStreamPrimaryColor,
                          padding: const EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(20),
                          elevation: 0,
                        ),
                        badgeContent: Text(btController.cartItems.toString(),
                            style: fontButton(fontSize: 12)),
                        child: const Icon(Icons.shopping_cart_outlined),
                      );
              }),
            ),
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
              child: GetX<BottomTabController>(builder: (btController) {
                return btController.unreadNotifications.value == 0
                    ? const Icon(Remix.notification_2_line)
                    : badges.Badge(
                        position:
                            badges.BadgePosition.topEnd(top: -10, end: -4),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: kStreamPrimaryColor,
                          padding: const EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(20),
                          elevation: 0,
                        ),
                        badgeContent: Text(
                            btController.unreadNotifications.toString(),
                            style: fontButton(fontSize: 12)),
                        child: const Icon(Remix.notification_2_line),
                      );
              }),
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
                onPressed: () => Get.to(() => Menu(uid: widget.uid),
                    transition: Transition.cupertino),
                icon: const Icon(Remix.menu_3_line),
                color: kWhiteColor),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            width: context.width,
            color: const Color(0xff161820),
            child: TabBar(
              controller: tabController,
              indicatorColor: kStreamPrimaryColor,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: kStreamPrimaryColor),
              ),
              indicatorWeight: 4,
              labelColor: kStreamPrimaryColor,
              unselectedLabelColor: kWhiteColor.withValues(alpha: 0.7),
              labelStyle:
                  fontBody(fontSize: 16.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  fontBody(fontSize: 15.sp, fontWeight: FontWeight.w400),
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: "Search"),
                Tab(text: "Home"),
                Tab(text: "Movies"),
                Tab(text: "Web Series"),
                Tab(text: "Watchlist"),
                Tab(text: "Upcoming"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          SearchTab(uid: widget.uid),
          AllTab(uid: widget.uid),
          MoviesTab(uid: widget.uid),
          SeriesTab(uid: widget.uid),
          FavouriteTab(uid: widget.uid),
          UpcomingTab(uid: widget.uid),
        ],
      ),
    );
  }
}
