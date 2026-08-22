part of 'reel_video.dart';

extension _ReelVideoStateExt3 on _ReelVideoState {
  Widget buildMain(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (videoPlayerController.value.isPlaying) {
          videoPlayerController.pause(); //pausing  functionality
        } else {
          videoPlayerController.play(); //playing functionality
        }
      },
      child: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          videoPlayerController.value.isInitialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: VisibilityDetector(
                      key: ObjectKey(videoPlayerController),
                      onVisibilityChanged: (visibility) {
                        if (visibility.visibleFraction == 0 && mounted) {
                          videoPlayerController
                              .pause(); //pausing  functionality
                        }
                      },
                      child: VideoPlayer(videoPlayerController),
                    ),
                  ),
                )
              : Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.reelData["thumbnail"],
                    placeholder: (context, url) =>
                        ColoredBox(color: kBlackColor.withValues(alpha: 0.2)),
                    width: context.width,
                    fit: BoxFit.fitWidth,
                  ),
                ),
          Container(
            width: context.width,
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: ReelsService().getUser(widget.reelData["uid"]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }
                          if (snapshot.hasData && !snapshot.data!.exists) {
                            widget.reelData.reference.delete();
                            return const SizedBox();
                          }
                          DocumentSnapshot user = snapshot.data!;
                          return ListTile(
                            onTap: () => Get.toNamed(
                              "/public_profile",
                              parameters: {"userID": widget.reelData["uid"]},
                            ),
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: SizedBox(
                                height: 35,
                                width: 35,
                                child: CachedNetworkImage(
                                  imageUrl: user["profileImage"],
                                  placeholder: (context, url) => ColoredBox(
                                    color: kWhiteColor.withValues(alpha: 0.2),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            minLeadingWidth: 0,
                            title: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              children: [
                                Text(
                                  user["name"],
                                  maxLines: 1,
                                  style: fontBody(
                                    color: kWhiteColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: kBlackColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.uid != widget.reelData["uid"])
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: ReelsService().getFollowingStream(
                                      widget.uid,
                                      widget.reelData["uid"],
                                    ),
                                    builder: (context, snapshot) {
                                      bool isFollowing = false;
                                      if (!snapshot.hasData) {
                                        isFollowing = false;
                                      }
                                      if (snapshot.hasData &&
                                          snapshot.data!.exists) {
                                        isFollowing = true;
                                      }

                                      return ElevatedButton(
                                        onPressed: () => isFollowing
                                            ? unfollowUser(
                                                widget.reelData["uid"],
                                              )
                                            : followUser(
                                                widget.reelData["uid"],
                                              ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kWhiteColor
                                              .withValues(alpha: 0.1),
                                          foregroundColor: kWhiteColor,
                                          elevation: 0,
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          isFollowing ? "Unfollow" : "Follow",
                                          style: fontBody(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              "${user["followers"]} followers",
                              style: fontBody(
                                color: kWhiteColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: kBlackColor.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (widget.reelData["caption"].isNotEmpty)
                        ReadMoreText(
                          widget.reelData["caption"],
                          trimLines: 2,
                          style: fontBody(
                            color: kWhiteColor,
                            fontSize: 15,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: kBlackColor.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                          colorClickableText: kWhiteColor,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: '- More',
                          trimExpandedText: '- Less',
                          moreStyle: fontBody(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: kBlackColor.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                          lessStyle: fontBody(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: kBlackColor.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.reelData["uid"] == widget.uid)
                        DecoratedBox(
                          decoration: ShapeDecoration(
                            color: kWhiteColor.withValues(alpha: 0.1),
                            shape: const CircleBorder(),
                          ),
                          child: IconButton(
                            tooltip: "Delete reel",
                            onPressed: () =>
                                deleteReel(widget.reelData.reference),
                            icon: Icon(
                              Remix.delete_bin_2_fill,
                              color: kButtonColor,
                              shadows: [
                                Shadow(
                                  color: kGreyColor1.withValues(alpha: 0.4),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          color: kWhiteColor.withValues(alpha: 0.1),
                          shape: const CircleBorder(),
                        ),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: ReelsService().getLikeStream(
                            widget.reelData.id,
                            widget.uid,
                          ),
                          builder: (context, snapshot) {
                            bool liked = false;
                            if (!snapshot.hasData) {
                              liked = false;
                            }
                            if (snapshot.hasData && snapshot.data!.exists) {
                              liked = true;
                            }
                            return IconButton(
                              tooltip: "Like",
                              onPressed: () => toggleReelLike(liked),
                              icon: liked
                                  ? const Icon(
                                      Remix.heart_2_fill,
                                      color: Colors.red,
                                    )
                                  : Icon(
                                      Remix.heart_2_line,
                                      color: kWhiteColor,
                                      shadows: [
                                        Shadow(
                                          color: kGreyColor1.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                      ),
                      Text(
                        Numeral(
                          widget.reelData["likes"],
                        ).format(fractionDigits: 2),
                        style: fontBody(color: kWhiteColor, fontSize: 12),
                      ),
                      if (widget.reelData["enableComment"])
                        const SizedBox(height: 20),
                      if (widget.reelData["enableComment"])
                        DecoratedBox(
                          decoration: ShapeDecoration(
                            color: kWhiteColor.withValues(alpha: 0.1),
                            shape: const CircleBorder(),
                          ),
                          child: IconButton(
                            tooltip: "Comment",
                            onPressed: () => openComments(),
                            icon: Icon(
                              Remix.message_2_fill,
                              color: kWhiteColor,
                              shadows: [
                                Shadow(
                                  color: kGreyColor1.withValues(alpha: 0.4),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.reelData["enableComment"])
                        Text(
                          Numeral(
                            widget.reelData["comments"],
                          ).format(fractionDigits: 2),
                          style: fontBody(color: kWhiteColor, fontSize: 12),
                        ),
                      if (widget.reelData["enableSharing"])
                        const SizedBox(height: 20),
                      if (widget.reelData["enableSharing"])
                        DecoratedBox(
                          decoration: ShapeDecoration(
                            color: kWhiteColor.withValues(alpha: 0.1),
                            shape: const CircleBorder(),
                          ),
                          child: IconButton(
                            tooltip: "Share",
                            onPressed: () {
                              Get.find<AdsService>().showRewardedAd(1);
                              ContentService.instance.shareReel(
                                id: widget.reelData.id,
                                fileUrl: widget.reelData["thumbnail"],
                                page: "reels",
                              );
                              widget.reelData.reference.update({
                                "shares": FieldValue.increment(1),
                              });
                            },
                            icon: Icon(
                              Remix.share_forward_fill,
                              color: kWhiteColor,
                              shadows: [
                                Shadow(
                                  color: kGreyColor1.withValues(alpha: 0.4),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.reelData["enableSharing"])
                        Text(
                          Numeral(
                            widget.reelData["shares"],
                          ).format(fractionDigits: 2),
                          style: fontBody(color: kWhiteColor, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 20,
            child: AnimatedOpacity(
              opacity: isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 600),
              child: TextButton.icon(
                onPressed: () {
                  if (videoPlayerController.value.isPlaying) {
                    videoPlayerController.pause(); //pausing  functionality
                  }
                  openTrendReelReport(
                    reelID: widget.reelData.id,
                    uid: widget.uid,
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: kWhiteColor.withValues(alpha: 0.1),
                  foregroundColor: kButtonColor,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                icon: Icon(
                  Icons.report,
                  shadows: [
                    Shadow(
                      color: kButtonColor.withValues(alpha: 0.4),
                      blurRadius: 5,
                    ),
                  ],
                ),
                label: Text(
                  "Report",
                  style: fontButton(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: kButtonColor.withValues(alpha: 0.4),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // center
          Positioned(
            top: context.height / 2 - 120,
            left: context.width / 2 - 37.5,
            child: AnimatedOpacity(
              opacity: isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 600),
              child: isPlaying
                  ? Container(
                      width: 75,
                      height: 75,
                      decoration: ShapeDecoration(
                        color: kWhiteColor.withValues(alpha: 0.2),
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Remix.pause_fill,
                        size: 40,
                        color: kWhiteColor,
                      ),
                    )
                  : Container(
                      width: 75,
                      height: 75,
                      decoration: ShapeDecoration(
                        color: kWhiteColor.withValues(alpha: 0.2),
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Remix.play_fill,
                        size: 40,
                        color: kWhiteColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
