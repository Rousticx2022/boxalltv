import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numeral/numeral.dart';
import 'package:readmore/readmore.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/bottomtab_controller.dart';
import '../../controllers/post_details_controller.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/styles.dart';
import '../../widgets/comment_box.dart';
import '../../widgets/like_button.dart';
import '../../widgets/post_type.dart';

class PostDetails extends GetView<PostDetailsController> {
  const PostDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post",
            style: fontHeading(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                color: kWhiteColor)),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(left: 20),
            decoration: const ShapeDecoration(
                shape: CircleBorder(), color: Colors.white10),
            child:
                const Icon(Remix.arrow_left_line, color: kSocialPrimaryColor),
          ),
        ),
        actions: [
          Obx(
            () => controller.postData["uid"] != controller.uid
                ? StreamBuilder<DocumentSnapshot>(
                    stream: usersCollection
                        .doc(controller.uid)
                        .collection("friends")
                        .doc(controller.postData["uid"])
                        .snapshots(),
                    builder: (context, usnapshot) {
                      if (!usnapshot.hasData) return const SizedBox();

                      DocumentSnapshot udata = usnapshot.data!;

                      if (usnapshot.hasData && udata.exists) {
                        return const SizedBox();
                      }

                      return Center(
                        child: TextButton(
                          onPressed: () async {
                            customSnackBar(text: "Request sent");
                            await usersCollection
                                .doc(controller.uid)
                                .collection("friends")
                                .doc(controller.postData["uid"])
                                .set({
                              "status": "requested",
                              "addedAt": DateTime.now(),
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: kSocialPrimaryColor,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Remix.user_add_fill, size: 15),
                              const SizedBox(width: 4),
                              Text('Friend',
                                  style: customTextStyleBody(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      );
                    })
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Obx(
        () => controller.postData.isEmpty
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        FutureBuilder<DocumentSnapshot>(
                            future: usersCollection
                                .doc(controller.postData["uid"])
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }
                              DocumentSnapshot udata = snapshot.data!;
                              return ListTile(
                                onTap: () => Get.toNamed("/public_profile",
                                    parameters: {"userID": udata.id}),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: kBlackColor,
                                    border: Border.all(
                                        color: kGreyColor2, width: 1.5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CachedNetworkImage(
                                      imageUrl: udata["profileImage"],
                                      fit: BoxFit.cover,
                                      placeholder: (c, s) => const ColoredBox(
                                          color: Colors.white10),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  udata["name"],
                                  maxLines: 2,
                                  style: customTextStyleHeadline(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  timeago.format(
                                      controller.postData["postDate"].toDate()),
                                  style: customTextStyleBody(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: kWhiteColor),
                                ),
                                trailing:
                                    controller.uid == controller.postData["uid"]
                                        ? InkWell(
                                            onTap: () => {},
                                            child: const Icon(Icons.more_horiz,
                                                color: kWhiteColor),
                                          )
                                        : null,
                              );
                            }),
                        if (controller.postData["caption"].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                            child: ReadMoreText(
                              controller.postData["caption"],
                              style: customTextStyleBody(fontSize: 15),
                              trimLines: 3,
                              colorClickableText: kWhiteColor,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Show more',
                              trimExpandedText: 'Show less',
                            ),
                          ),
                        if (controller.postData["content"].isNotEmpty)
                          SizedBox(
                            width: context.width,
                            height: context.width,
                            child: controller.postData["content"].length > 1
                                ? Swiper(
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return controller.postData["content"]
                                                  [index]["type"] ==
                                              "image"
                                          ? PostTypeImage(
                                              content: controller
                                                  .postData["content"][index])
                                          : PostTypeVideo(
                                              content: controller
                                                  .postData["content"][index],
                                              postID: controller.postID!);
                                    },
                                    itemCount:
                                        controller.postData["content"].length,
                                    viewportFraction: 1,
                                    itemWidth: context.width,
                                    loop: false,
                                    scale: 0.9,
                                    outer: true,
                                    indicatorLayout: PageIndicatorLayout.SCALE,
                                    pagination: SwiperPagination(
                                      margin: const EdgeInsets.only(top: 10.0),
                                      builder: DotSwiperPaginationBuilder(
                                          activeColor: kWhiteColor,
                                          color: kWhiteColor.withValues(alpha: 0.5)),
                                    ),
                                  )
                                : controller.postData["content"][0]["type"] ==
                                        "image"
                                    ? PostTypeImage(
                                        content: controller.postData["content"]
                                            [0])
                                    : PostTypeVideo(
                                        content: controller.postData["content"]
                                            [0],
                                        postID: controller.postID!),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                                child: LikeButton(
                                    uid: controller.uid,
                                    postOwner: controller.postData["uid"],
                                    postID: controller.postID!)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  if (!controller.keyboardFocus.hasFocus) {
                                    controller.keyboardFocus.requestFocus();
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: kWhiteColor,
                                  shape: const StadiumBorder(),
                                ),
                                label: Text(
                                    Numeral(controller.postData["comments"])
                                        .format(fractionDigits: 2),
                                    style: customTextStyleBody(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                                icon:
                                    const Icon(Remix.message_2_fill, size: 20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  Get.find<BottomTabController>()
                                      .shareSocialPosts(controller.postID!,
                                          controller.postData["content"]);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: kWhiteColor,
                                  shape: const StadiumBorder(),
                                ),
                                label: Text(
                                    Numeral(controller.postData["shares"])
                                        .format(fractionDigits: 2),
                                    style: customTextStyleBody(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                                icon: const Icon(Remix.share_forward_fill,
                                    size: 20),
                              ),
                            ),
                          ],
                        ),
                        FirestoreListView(
                          query: postDataCollection
                              .doc(controller.postID!)
                              .collection("comments")
                              .orderBy("postedOn", descending: true),
                          padding: const EdgeInsets.all(15),
                          scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          loadingBuilder: (c) => Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                children: [
                                  Icon(Remix.loader_2_fill,
                                      size: 30.sp, color: kWhiteColor),
                                  const SizedBox(height: 5),
                                  Text("Loading...",
                                      style: fontBody(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: kWhiteColor)),
                                ],
                              ),
                            ),
                          ),
                          emptyBuilder: (c) => Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                children: [
                                  Icon(Remix.message_3_fill,
                                      size: 30.sp, color: kWhiteColor),
                                  const SizedBox(height: 5),
                                  Text("No comments yet!",
                                      style: fontBody(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: kWhiteColor)),
                                ],
                              ),
                            ),
                          ),
                          itemBuilder: (context, comment) =>
                              commentBox(comment),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: kBlackColor),
                    child: TextFormField(
                      controller: controller.commentController,
                      style: customTextStyleBody(color: kWhiteColor),
                      textAlign: TextAlign.start,
                      focusNode: controller.keyboardFocus,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.withValues(alpha: 0.2),
                        filled: true,
                        hintText: "Write your comment",
                        suffixIcon: IconButton(
                          icon: const Icon(Remix.send_plane_fill),
                          color: kSocialPrimaryColor,
                          onPressed: () async {
                            if (controller.commentController.text
                                .trim()
                                .isEmpty) {
                              return;
                            }
                            await postDataCollection
                                .doc(controller.postID)
                                .collection("comments")
                                .add({
                              "comment":
                                  controller.commentController.text.trim(),
                              "commentator": controller.uid,
                              "postedOn": DateTime.now(),
                            }).then((value) async {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);

                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              controller.commentController.clear();
                              await postsCollection
                                  .doc(controller.postID)
                                  .update(
                                      {"comments": FieldValue.increment(1)});
                            });
                          },
                        ),
                        hintStyle: customTextStyleBody(color: kWhiteColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
