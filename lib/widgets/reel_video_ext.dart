part of 'reel_video.dart';

extension ReelVideoExt on _ReelVideoState {
  Future<void> openComments() async {
    Get.find<AdsService>().showRewardedAd(1);
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(top: kToolbarHeight * 3),
          decoration: const BoxDecoration(
            color: kBlackColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(10),
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                leading: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kWhiteColor.withValues(alpha: 0.1),
                  ),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Remix.close_line),
                    constraints:
                        const BoxConstraints(maxHeight: 35, maxWidth: 35),
                    padding: const EdgeInsets.all(5),
                    color: kWhiteColor,
                  ),
                ),
                title: Text("Comments",
                    style: fontBody(
                        fontSize: 20,
                        color: kWhiteColor,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: FirestoreListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  query: reelsCollection
                      .doc(widget.reelData.id)
                      .collection("comments")
                      .where("active", isEqualTo: true)
                      .orderBy("addedAt", descending: true),
                  emptyBuilder: (context) => Center(
                      child: Text("No comments yet",
                          style: fontBody(color: kWhiteColor))),
                  itemBuilder: (context, commentData) {
                    return FutureBuilder<DocumentSnapshot>(
                        future: ReelsService().getUser(commentData["uid"]),
                        builder: (context, csnapshot) {
                          if (!csnapshot.hasData) return const SizedBox();
                          if (csnapshot.hasData && !csnapshot.data!.exists) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: CachedNetworkImage(
                                    imageUrl: csnapshot.data!["profileImage"],
                                    placeholder: (context, url) => ColoredBox(
                                        color: kWhiteColor.withValues(alpha: 0.2)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              minLeadingWidth: 0,
                              tileColor: kWhiteColor.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              title: Text(
                                  "${csnapshot.data!["name"]} • ${timeago.format(commentData["addedAt"].toDate())}",
                                  style: fontBody(
                                      fontSize: 14,
                                      color: kWhiteColor,
                                      fontWeight: FontWeight.w600)),
                              subtitle: ReadMoreText(
                                commentData["comment"],
                                trimLines: 2,
                                style:
                                    fontBody(color: kWhiteColor, fontSize: 15),
                                colorClickableText: kWhiteColor,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: '- More',
                                trimExpandedText: '- Less',
                                moreStyle: fontBody(
                                    fontSize: 14,
                                    color: kWhiteColor.withValues(alpha: 0.7)),
                                lessStyle: fontBody(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              trailing: widget.uid == commentData["uid"]
                                  ? IconButton(
                                      onPressed: () async {
                                        commentData.reference.delete();
                                        await widget.reelData.reference.update({
                                          "comments": FieldValue.increment(-1)
                                        });
                                      },
                                      constraints:
                                          const BoxConstraints(maxWidth: 20),
                                      icon: const Icon(Remix.chat_delete_fill,
                                          size: 15, color: kButtonColor),
                                    )
                                  : IconButton(
                                      onPressed: () =>
                                          reportComment(commentData.reference),
                                      constraints:
                                          const BoxConstraints(maxWidth: 20),
                                      icon: const Icon(Icons.report,
                                          size: 15, color: kGreyColor1),
                                    ),
                            ),
                          );
                        });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: kWhiteColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: TextField(
                      controller: commentController,
                      style: fontBody(fontSize: 16, color: kWhiteColor),
                      cursorColor: kWhiteColor,
                      decoration: InputDecoration(
                        hintText: "Add a comment",
                        hintStyle: fontBody(
                            fontSize: 16, color: kWhiteColor.withValues(alpha: 0.65)),
                        border: InputBorder.none,
                      ),
                    ),
                    trailing: DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kBlackColor,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          sendComment();
                        },
                        icon: const Icon(Remix.send_plane_2_fill,
                            color: kReelsPrimaryColor),
                        constraints:
                            const BoxConstraints(maxHeight: 35, maxWidth: 35),
                        padding: const EdgeInsets.all(10),
                        iconSize: 16,
                        color: kBlackColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void updateEngagement() {
    widget.reelData.reference.update({"engagement": FieldValue.increment(1)});
  }

  Future<void> followUser(String userID) async {
    if (followButtonLoading) return;
    followButtonLoading = true;
    await ReelsService().followUser(widget.uid, userID);
    followButtonLoading = false;
  }

  Future<void> unfollowUser(String userID) async {
    if (followButtonLoading) return;
    followButtonLoading = true;
    await ReelsService().unfollowUser(widget.uid, userID);
    followButtonLoading = false;
  }

  // Random random = Random();

  void showRewardedAdReel(int coins) {
    if (!widget.showAd) return;

    if (bottomTabController.userData["accountType"] == "premium") {
      return;
    }

    if (adsService.rewardedAd == null) {
      return;
    }

    adsService.rewardedAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        videoPlayerController.pause();
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        videoPlayerController.play();
        ad.dispose();
        adsService.createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        videoPlayerController.play();
        ad.dispose();
        adsService.createRewardedAd();
      },
    );
    adsService.rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      adsService.updateReward(coins);
    });
    adsService.rewardedAd = null;
  }

  void initState() {
    showRewardedAdReel(1);

    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.reelData["video"]))
          ..initialize().then((_) async {
            videoPlayerController.play();

            videoPlayerController.setLooping(true);

            setState(() {});
          });

    updateEngagement();
    videoPlayerController.addListener(() {
      setState(() {
        isPlaying = videoPlayerController.value.isPlaying;
      });
    });
  }
}
