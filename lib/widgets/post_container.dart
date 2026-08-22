import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:numeral/numeral.dart';
import 'package:readmore/readmore.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/models.dart';
import '../controllers/upload_controller.dart';
import '../news_feed_multiple_image_view/src/newsfeed_multiple_imageview.dart';
import '../services/ads_service.dart';
import '../services/content_service.dart';
import '../services/purchase_service.dart';
import '../utils/collections.dart';
import 'like_button.dart';

class PostContainer extends StatelessWidget {
  const PostContainer({
    super.key,
    required this.posts,
    required this.uid,
    this.routeToProfile = true,
    required this.confirmDelete,
  });
  final Posts posts;
  final String uid;
  final bool routeToProfile;
  final Function confirmDelete;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: usersCollection.doc(posts.uid).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              DocumentSnapshot udata = snapshot.data!;
              return ListTile(
                onTap: () => routeToProfile
                    ? Get.toNamed(
                        "/public_profile",
                        parameters: {"userID": udata.id},
                      )
                    : {},
                leading: Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: kBlackColor,
                    border: Border.all(color: kGreyColor2, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: udata["profileImage"],
                      fit: BoxFit.cover,
                      placeholder: (c, s) =>
                          const ColoredBox(color: Colors.white10),
                    ),
                  ),
                ),
                minLeadingWidth: 0,
                title: Text(
                  udata["name"],
                  maxLines: 2,
                  style: customTextStyleHeadline(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  timeago.format(posts.postDate.toDate()),
                  style: customTextStyleBody(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: kWhiteColor,
                  ),
                ),
                trailing: uid == posts.uid
                    ? MenuAnchor(
                        alignmentOffset: const Offset(-50, 0),
                        builder:
                            (
                              BuildContext context,
                              MenuController controller,
                              Widget? child,
                            ) {
                              return IconButton(
                                onPressed: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                },
                                padding: const EdgeInsets.all(0),
                                icon: const Icon(Icons.more_horiz),
                                tooltip: 'Show options',
                              );
                            },
                        menuChildren: [
                          // MenuItemButton(
                          //   onPressed: () => {},
                          //   leadingIcon: Icon(Icons.edit, color: kSocialPrimaryColor, size: 16.sp),
                          //   child: Text('Edit', style: fontButton(fontSize: 15.sp, color: kSocialPrimaryColor)),
                          // ),
                          MenuItemButton(
                            onPressed: () => confirmDelete(posts.postID),
                            leadingIcon: Icon(
                              Icons.delete,
                              color: kSocialPrimaryColor,
                              size: 16.sp,
                            ),
                            child: Text(
                              'Delete',
                              style: fontButton(
                                fontSize: 15.sp,
                                color: kSocialPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              );
            },
          ),
          if (posts.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: ReadMoreText(
                posts.caption,
                style: customTextStyleBody(fontSize: 15.sp),
                trimLines: 3,
                colorClickableText: kWhiteColor,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
              ),
            ),
          if (posts.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: NewsfeedMultipleImageView(
                imageUrls: posts.content,
                marginLeft: 0,
                marginRight: 0,
                marginBottom: 5.0,
                marginTop: 5.0,
              ),
            ),
          if (posts.isTrimmed)
            FutureBuilder<DocumentSnapshot>(
              future: videosCollection.doc(posts.vid).get(),
              builder: (context, vsnapshot) {
                if (!vsnapshot.hasData) {
                  return const SizedBox();
                }

                DocumentSnapshot vdata = vsnapshot.data!;

                if (vsnapshot.hasData && !vdata.exists) {
                  return const SizedBox();
                }
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      imageUrl: vdata["banner"],
                      fit: BoxFit.cover,
                      height: 45,
                      width: 70,
                    ),
                  ),
                  title: Text(
                    vdata["title"],
                    maxLines: 1,
                    style: fontBody(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    vdata["genres"].join(", "),
                    maxLines: 1,
                    style: fontBody(fontSize: 14.sp),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      if (vdata["type"] == "FREE") {
                        Get.toNamed(
                          "/watch",
                          parameters: {
                            "uid": uid,
                            "vid": vdata.id,
                            "type": vdata["type"],
                            "section": vdata["section"],
                            "episodeID": "",
                            "seek": posts.recordingStartedFrom.toString(),
                          },
                        );
                        return;
                      }
                      if (vdata["type"] == "RENT") {
                        DocumentSnapshot purchasedVideo = await usersCollection
                            .doc(uid)
                            .collection("purchases")
                            .doc(vdata.id)
                            .get();
                        bool isPurchased = false;
                        if (purchasedVideo.exists) {
                          DateTime validity = DateTime.parse(
                            purchasedVideo['validity'].toDate().toString(),
                          );
                          if (!validity.difference(DateTime.now()).isNegative) {
                            isPurchased = true;
                          } else {
                            isPurchased = false;
                          }
                        }
                        if (!isPurchased) {
                          Get.find<PurchaseService>().makePayment(
                            amount: vdata["pricing"]["amount"].toDouble(),
                            uid: uid,
                            vid: vdata.id,
                            validity: vdata["pricing"]["validity"],
                          );
                        } else {
                          Get.toNamed(
                            "/watch",
                            parameters: {
                              "uid": uid,
                              "vid": vdata.id,
                              "type": vdata["type"],
                              "section": vdata["section"],
                              "episodeID": "",
                              "seek": posts.recordingStartedFrom.toString(),
                            },
                          );
                        }
                        return;
                      }
                      customSnackBar(
                        text: "Please subscribe to watch this video",
                      );
                    },
                    style: TextButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: kSocialPrimaryColor,
                      foregroundColor: kBlackColor,
                    ),
                    child: Text(
                      "Origin",
                      style: fontButton(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: LikeButton(
                    uid: uid,
                    postOwner: posts.uid,
                    postID: posts.postID,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Get.toNamed("/post", parameters: {"postID": posts.postID});
                      Get.find<AdsService>().showRewardedAd(1);
                      Get.find<UploadController>().openPostCommentsSheet(
                        uid: uid,
                        postOwner: posts.uid,
                        postID: posts.postID,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: kWhiteColor,
                      shape: const StadiumBorder(),
                    ),
                    label: Text(
                      Numeral(posts.comments).format(fractionDigits: 2),
                      style: customTextStyleBody(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    icon: const Icon(Remix.message_2_fill, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Get.find<AdsService>().showRewardedAd(1);
                      // Get.find<BottomTabController>().shareSocialPosts(posts.postID, posts.content);
                      ContentService.instance.shareFeed(
                        id: posts.postID,
                        page: "feeds",
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: kWhiteColor,
                      shape: const StadiumBorder(),
                    ),
                    label: Text(
                      Numeral(posts.shares).format(fractionDigits: 2),
                      style: customTextStyleBody(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    icon: const Icon(Remix.share_forward_fill, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
