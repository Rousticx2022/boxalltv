import '../utils/movie_cast_builder.dart';
import 'package:boxalltv/widgets/watch_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:boxalltv/views/trailer.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/container_builder.dart';
import '../utils/placeholder_rails.dart';
import '../utils/collections.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import '../controllers/details_controller.dart';

import '../utils/styles.dart';

class Details extends GetView<DetailsController> {
  const Details({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: controller.fetchVideoDetails(),
          builder: (context, vSnapshot) {
            if (!vSnapshot.hasData) {
              return Center(
                  child: customCircularProgress(
                      strokeColor: context.theme.primaryColor));
            }
            DocumentSnapshot videoDetails = vSnapshot.data!;
            return ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: kToolbarHeight - 20),
                      width: context.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: videoDetails["banner"],
                          placeholder: (context, url) =>
                              Image.asset("assets/placeholder3.gif"),
                          errorWidget: (context, url, error) =>
                              Image.asset("assets/placeholder3.gif"),
                          width: context.width,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 30,
                      top: kToolbarHeight - 10,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(100)),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: kWhiteColor, size: 25),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: kToolbarHeight - 10,
                      right: 30,
                      child: OverflowBar(
                        alignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleLike(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: Colors.black45),
                              child: Obx(() => Icon(
                                  controller.videoInteraction.isNotEmpty
                                      ? controller.thumbs_up()
                                      : Icons.thumb_up_alt,
                                  color: kWhiteColor,
                                  size: 19.sp)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.toggleDisLike(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: Colors.black45),
                              child: Obx(() => Icon(
                                  controller.videoInteraction.isNotEmpty
                                      ? controller.thumbs_down()
                                      : Icons.thumb_down_alt,
                                  color: kWhiteColor,
                                  size: 19.sp)),
                            ),
                          ),
                          StreamBuilder<DocumentSnapshot>(
                              stream: controller.fetchWatchlistStatus(),
                              builder: (context, snapshot) {
                                bool exists = false;

                                if (!snapshot.hasData) {
                                  exists = false;
                                }

                                if (snapshot.hasData) {
                                  exists = snapshot.data!.exists;
                                }

                                return GestureDetector(
                                  onTap: () async {
                                    await controller.toggleWatchlist(exists, videoDetails);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        color: Colors.black45),
                                    child: Icon(
                                        exists
                                            ? Remix.heart_fill
                                            : Remix.heart_add_line,
                                        color: kWhiteColor,
                                        size: 19.sp),
                                  ),
                                );
                              }),
                          // GestureDetector(
                          //   onTap: () => {},
                          //   child: Container(
                          //     padding: const EdgeInsets.all(12),
                          //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(100.0), color: kWhiteColor.withOpacity(0.15)),
                          //     child: const Icon(Icons.share, color: kWhiteColor, size: 20),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${videoDetails["contentRating"]}  |  ",
                              style: customTextStyleBody(
                                  color: kWhiteColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp)),
                          Text("${videoDetails["publish"]}  |  ",
                              style: customTextStyleBody(
                                  color: kWhiteColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500)),
                          Text(point3(videoDetails),
                              style: customTextStyleBody(
                                  color: kWhiteColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500))
                        ],
                      ),
                      Text(
                        videoDetails["title"],
                        style: customTextStyleHeadline(fontSize: 22.sp),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(videoDetails["genres"].join(', '),
                          style: customTextStyleHeadline(
                              color: Colors.grey.shade400,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold)),
                      Container(
                        width: context.width,
                        margin: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                if (videoDetails["trailer"].isEmpty) {
                                  customSnackBar(text: "Trailer coming soon");
                                  return;
                                }
                                Get.to(() => Trailer(
                                    video: videoDetails["trailer"],
                                    title: videoDetails["title"]));
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: kWhiteColor.withValues(alpha: 0.15),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                              ),
                              child: Text("Trailer",
                                  style: customTextStyleBody(fontSize: 16.sp)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: WatchButton(
                                vid: controller.vid!,
                                uid: controller.uid!,
                                pricing: videoDetails["pricing"],
                                title: videoDetails["title"],
                                type: videoDetails["type"],
                                section: videoDetails["section"],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text("Storyline",
                          style: GoogleFonts.cabin(
                              fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      ReadMoreText(
                        videoDetails["storyline"],
                        trimLines: 3,
                        style: customTextStyleBody(fontSize: 16.sp),
                        colorClickableText: kButtonColor,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'more',
                        trimExpandedText: 'less',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Reviews",
                              style: GoogleFonts.cabin(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () =>
                                controller.addRating(videoDetails["title"]),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: kWhiteColor.withValues(alpha: 0.15)),
                              child: Icon(Icons.add,
                                  color: kWhiteColor, size: 19.sp),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Obx(
                        () => controller.reviews.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                    color: kWhiteColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(15)),
                                height: 150,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.rate_review),
                                      Text("No reviews yet",
                                          style: customTextStyleBody(
                                              fontSize: 16.sp)),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.reviews.length,
                                itemBuilder: (context, index) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: kWhiteColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(
                                            controller.reviews[index]["name"],
                                            style: customTextStyleHeadline(
                                                fontSize: 17.sp),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 16.sp),
                                              Text(
                                                "${controller.reviews[index]["rating"].round()}",
                                                style: customTextStyleHeadline(
                                                    fontSize: 16.sp),
                                              )
                                            ],
                                          ),
                                          subtitle: Text(
                                              timeago.format(controller
                                                  .reviews[index]["postDate"]
                                                  .toDate()),
                                              style: customTextStyleBody(
                                                  fontSize: 12.sp)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20.0, 0, 20, 15),
                                          child: ReadMoreText(
                                            controller.reviews[index]["review"],
                                            trimLines: 2,
                                            colorClickableText: kPrimaryColor,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'Show more',
                                            trimExpandedText: 'Show less',
                                            style: customTextStyleBody(
                                                fontSize: 14.sp),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(height: 10),
                              ),
                      ),
                      Obx(
                        () => controller.reviews.length < 2
                            ? const SizedBox.shrink()
                            : Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => controller.loadAllReviews(),
                                  icon: Text("All reviews",
                                      style:
                                          customTextStyleBody(fontSize: 15.sp)),
                                  label: Icon(Icons.arrow_forward_ios,
                                      size: 16.sp, color: kButtonColor),
                                ),
                              ),
                      ),
                      MovieCastBuilder().movieCast(controller.vid!),
                      MovieCastBuilder().movieCrew(controller.vid!),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                          stream: controller.fetchRelatedVideos(videoDetails['genres']),
                          builder: (context, rSnapshot) {
                            if (!rSnapshot.hasData) {
                              return PlaceholderRails.instance
                                  .buildPortraitPlaceholder(context);
                            }
                            List<DocumentSnapshot> moreList =
                                rSnapshot.data!.docs;
                            if (rSnapshot.hasData && moreList.isEmpty) {
                              return Container();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Watch More",
                                      style: fontBody(fontSize: 17.sp)),
                                  Container(
                                    height: 20.h,
                                    margin: const EdgeInsets.only(top: 5),
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: moreList.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ContainerBuilder(
                                                  uid: controller.uid!)
                                              .videoContainerPortrait(
                                                  context, moreList[index],
                                                  replace: true);
                                        }),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  String point3(DocumentSnapshot vData) {
    if (vData["section"] == "series") {
      return "${vData["seasons"]}${vData["seasons"] < 2 ? " Season" : " Seasons"}";
    }
    return vData["duration"];
  }
}
