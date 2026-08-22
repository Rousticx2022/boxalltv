import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/services/ads_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/bottomtab_controller.dart';
import '../../utils/models.dart';
import '../../utils/collections.dart';
import '../../widgets/post_container.dart';

class FeedTab extends StatefulWidget {
  final String uid;
  const FeedTab({super.key, required this.uid});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  int count = 0;
  ScrollController scrollController = ScrollController();
  BottomTabController bottomTabController = Get.find();
  AdsService adsService = Get.find();

  bool fetchingPosts = false;

  DocumentSnapshot? firstVisiblePost;
  DocumentSnapshot? lastVisiblePost;

  List<DocumentSnapshot> postsList = [];

  void confirmDelete(String postID) {
    Get.defaultDialog(
      title: "Delete Post",
      titleStyle: fontHeading(
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        color: kWhiteColor,
      ),
      content: Text(
        "Are you sure you want\nto delete this post?",
        style: fontBody(),
        textAlign: TextAlign.center,
      ),
      barrierDismissible: false,
      backgroundColor: kGreyColor2,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            backgroundColor: kBlackColor,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          ),
          child: Text(
            "Close",
            style: customTextStyleBody(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await postsCollection.doc(postID).update({"active": false});

            customSnackBar(text: "Post deleted successfully");
          },
          style: TextButton.styleFrom(
            backgroundColor: kButtonColor,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          ),
          child: Text(
            "Delete",
            style: customTextStyleBody(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  void showRewardedAdReel(int coins) {
    if (bottomTabController.userData["accountType"] == "premium") {
      return;
    }

    if (adsService.rewardedAd == null) {
      return;
    }

    adsService.rewardedAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad) {},
          onAdDismissedFullScreenContent: (RewardedAd ad) {
            ad.dispose();
            adsService.createRewardedAd();
          },
          onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
            ad.dispose();
            adsService.createRewardedAd();
          },
        );
    adsService.rewardedAd?.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        adsService.updateReward(coins);
      },
    );
    adsService.rewardedAd = null;
  }

  Future<void> fetchPosts() async {
    final QuerySnapshot snapshot = await postsCollection
        .where("active", isEqualTo: true)
        .orderBy('postDate', descending: true)
        .limit(4)
        .get();
    if (snapshot.docs.isNotEmpty) {
      postsList = snapshot.docs;

      setState(() {});
      firstVisiblePost = snapshot.docs.first;
      lastVisiblePost = snapshot.docs.last;
    }
  }

  Future<void> fetchNextPosts() async {
    if (postsList.length > 30) {
      fetchPosts();
      customSnackBar(text: "Feeds refreshed");
      return;
    }

    customSnackBar(text: postsList.length.toString());

    if (postsList.length % 10 == 0) {
      showRewardedAdReel(1);
    }

    setState(() {
      fetchingPosts = true;
    });

    final QuerySnapshot snapshot = await postsCollection
        .where("active", isEqualTo: true)
        .orderBy('postDate', descending: true)
        .startAfterDocument(lastVisiblePost!)
        .limit(4)
        .get();
    if (snapshot.docs.isNotEmpty) {
      postsList.addAll(snapshot.docs);

      fetchingPosts = false;
      lastVisiblePost = snapshot.docs.last;
      setState(() {});
    }
  }

  @override
  void initState() {
    fetchPosts();

    scrollController.addListener(() {
      if (scrollController.position.pixels -
                  scrollController.position.maxScrollExtent >
              -100 &&
          fetchingPosts == false) {
        fetchNextPosts();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20),
      shrinkWrap: true,
      addAutomaticKeepAlives: false,
      itemCount: postsList.length,
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      // pageSize: 3,
      // query: postsCollection.where("active", isEqualTo: true).orderBy('postDate', descending: true),
      itemBuilder: (context, index) {
        Posts post = Posts.fromDocument(postsList[index]);

        return PostContainer(
          posts: post,
          uid: widget.uid,
          confirmDelete: confirmDelete,
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(color: kGreyColor1),
    );
  }
}
