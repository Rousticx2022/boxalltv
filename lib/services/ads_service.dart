import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../controllers/bottomtab_controller.dart';
import '../utils/collections.dart';

class AdsService extends GetxService {
  AdRequest request = const AdRequest();
  List<DocumentSnapshot> videoAdsList = [];
  DateTime lastSocialAdLoaded =
      DateTime.now().subtract(const Duration(seconds: 20));

  String uid = FirebaseAuth.instance.currentUser!.uid;

  RewardedAd? rewardedAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  NativeAd? nativeAd;
  RxBool nativeAdIsLoaded = false.obs;

  final String nativeAdsID = Platform.isAndroid
      ? 'ca-app-pub-8007198540452738/2789012229'
      : 'ca-app-pub-8007198540452738/6508765386';
  final String rewardedAdsID = Platform.isAndroid
      ? 'ca-app-pub-8007198540452738/1280854398'
      : 'ca-app-pub-8007198540452738/1615531353';

  Timer? earnRewardTimer;
  RxInt rewardTimer = 20.obs;
  RxBool isRewardingTimer = false.obs;

  void startEarnRewardTimer() {
    earnRewardTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (rewardTimer.value == 0) {
        timer.cancel();
        rewardTimer.value = 20;
        isRewardingTimer.value = false;
        return;
      } else {
        isRewardingTimer.value = true;
        rewardTimer.value -= 1;
      }
    });
  }

  Future<void> updateReward(int coins, {bool forSharing = false}) async {
    await usersCollection.doc(uid).update({
      "wallet": FieldValue.increment(coins),
    });
    if (forSharing) {
      Share.share(
          "Download Frame app and earn coins. https://play.google.com/store/apps/details?id=com.shaderbytes.frame");
    }
  }

  void createRewardedAd() {
    if (rewardedAd != null) {
      return;
    }

    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-2406494975800826/1247341631'
            : 'ca-app-pub-2406494975800826/9020452811',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            rewardedAd = ad;
            _numInterstitialLoadAttempts = 0;
            rewardedAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            rewardedAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createRewardedAd();
            }
          },
        ));
  }

  bool showRewardedAd(int coins) {
    BottomTabController bottomTabController = Get.find();

    if (bottomTabController.userData["accountType"] == "premium") {
      return false;
    }

    if (rewardedAd == null) {
      return false;
    }

    bool res = false;

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        // flickManager.flickControlManager!.pause();
        res = true;
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        // flickManager.flickControlManager!.play();
        ad.dispose();
        createRewardedAd();
        res = false;
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        // adsShown += 1;
        // flickManager.flickControlManager!.play();
        ad.dispose();
        createRewardedAd();
        res = false;
      },
    );
    rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      updateReward(coins);
    });
    rewardedAd = null;
    return res;
  }

  bool showRewardedAdEarn(int coins, {bool forSharing = false}) {
    if (rewardedAd == null) {
      return false;
    }

    bool res = false;

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        // flickManager.flickControlManager!.pause();
        res = true;
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        // flickManager.flickControlManager!.play();
        ad.dispose();
        createRewardedAd();
        res = false;
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        // adsShown += 1;
        // flickManager.flickControlManager!.play();
        ad.dispose();
        createRewardedAd();
        res = false;
      },
    );
    rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      updateReward(coins, forSharing: forSharing);
    });
    rewardedAd = null;
    return res;
  }

  Future<void> loadCustomAds() async {
    QuerySnapshot videoAds = await customVideoAdsCollection
        .where("active", isEqualTo: true)
        .where("status", isEqualTo: "ongoing")
        .where("totalBudget", isGreaterThan: 0)
        .where("zipcodes",
            arrayContains: Get.find<BottomTabController>().userData["zipcode"])
        .orderBy("budgetPerAds", descending: true)
        .limit(10)
        .get();

    if (videoAds.docs.isNotEmpty) {
      videoAdsList.addAll(videoAds.docs);
    }

    videoAdsList.shuffle();
  }

  Future<void> reloadCustomAds() async {
    videoAdsList.shuffle();
  }

  Future<String> showCustomAds() async {
    if (videoAdsList.isEmpty) {
      loadCustomAds();
      return "";
    }

    String videoURL = videoAdsList.first["url"];
    await customVideoAdsCollection.doc(videoAdsList.first.id).update({
      "totalBudget": FieldValue.increment(-videoAdsList.first["budgetPerAds"]),
      "totalAdsShown": FieldValue.increment(1),
    });
    videoAdsList.remove(videoAdsList.first);
    reloadCustomAds();
    return videoURL;
  }

  @override
  void onInit() {
    loadCustomAds();
    createRewardedAd();

    super.onInit();
  }
}

class CustomVideoAd extends StatefulWidget {
  final String url;
  const CustomVideoAd({super.key, required this.url});

  @override
  State<CustomVideoAd> createState() => _CustomVideoAdState();
}

class _CustomVideoAdState extends State<CustomVideoAd> {
  late FlickManager flickManager;
  bool loaded = false;
  RxInt elapsedSeconds = 0.obs;

  @override
  void initState() {
    flickManager = FlickManager(
      videoPlayerController:
          VideoPlayerController.networkUrl(Uri.parse(widget.url)),
      onVideoEnd: () {
        Get.back();
        customSnackBar(text: "Removing custom ads");
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                  child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FlickVideoPlayer(
                  flickManager: flickManager,
                  flickVideoWithControls: const FlickVideoWithControls(
                      // controls: FlickPortraitControls(),
                      ),
                  flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                      // controls: FlickLandscapeControls(),
                      ),
                ),
              )),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: kWhiteColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text("Playing ad", style: fontBody(color: kWhiteColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget>
    with WidgetsBindingObserver {
  NativeAd? _nativeAd;
  bool adLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    BottomTabController bottomTabController = Get.find();

    if (bottomTabController.userData["accountType"] == "premium") {
      return;
    }

    // customSnackBar(text: "${DateTime.now().difference(Get.find<AdsService>().lastSocialAdLoaded).inSeconds}");
    if (DateTime.now()
            .difference(Get.find<AdsService>().lastSocialAdLoaded)
            .inSeconds <
        20) {
      return;
    }

    _nativeAd = NativeAd(
      adUnitId: Get.find<AdsService>().nativeAdsID,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          Get.find<AdsService>().lastSocialAdLoaded = DateTime.now();
          setState(() {
            adLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // customSnackBar(text: error.message);
          ad.dispose();
        },
        onAdOpened: (ad) {
          // ad.dispose();
          Get.find<AdsService>().updateReward(1);
        },
      ),
      request: Get.find<AdsService>().request,
      nativeTemplateStyle: NativeTemplateStyle(
        // Required: Choose a template.
        templateType: TemplateType.medium,
        // Optional: Customize the ad's style.
        mainBackgroundColor: kBlackColor,
        cornerRadius: 20.0,
        callToActionTextStyle: NativeTemplateTextStyle(
            textColor: kBlackColor,
            backgroundColor: kSocialPrimaryColor,
            style: NativeTemplateFontStyle.monospace,
            size: 16.0),
        primaryTextStyle: NativeTemplateTextStyle(
            textColor: kBlackColor,
            backgroundColor: kSocialPrimaryColor,
            size: 16.0),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _nativeAd != null && adLoaded
        ? ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: context.width,
              minHeight: context.width - 30,
              maxWidth: context.width,
              maxHeight: context.width - 30,
            ),
            child: AdWidget(ad: _nativeAd!),
          )
        : const SizedBox.shrink();
  }
}
