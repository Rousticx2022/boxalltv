import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boxalltv/views/channel/add_episode.dart';
import 'package:boxalltv/views/channel/edit_episode.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../utils/styles.dart';
import 'collections.dart';
import 'ui_widgets.dart';

void openEpisodeList(
    {required String uid,
    required String vid,
    required String title,
    required String type}) {
  RxInt selectedSeasonIndex = 1.obs;
  Get.bottomSheet(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: 70.h,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(4),
                    decoration: const ShapeDecoration(
                        color: Colors.white12, shape: CircleBorder()),
                    child: const Icon(Icons.close),
                  ),
                ),
                Text("Episodes & info",
                    style: fontHeading(
                        fontSize: 20.sp, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 45,
              child: FutureBuilder<DocumentSnapshot>(
                  future: videosCollection.doc(vid).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemCount: snapshot.data!['seasons'],
                      itemBuilder: (context, index) {
                        return Obx(
                          () => FilterChip(
                            backgroundColor: kWhiteColor.withValues(alpha: 0.1),
                            selectedColor: kButtonColor,
                            label: Text("Season ${index + 1}",
                                style: fontButton(fontSize: 15.sp)),
                            selected: (index + 1) == selectedSeasonIndex.value,
                            onSelected: (selected) {
                              selectedSeasonIndex.value = index + 1;
                            },
                          ),
                        );
                      },
                    );
                  }),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(
                () => StreamBuilder<QuerySnapshot>(
                    stream: videosCollection
                        .doc(vid)
                        .collection("episodes")
                        .where("seasonNo", isEqualTo: selectedSeasonIndex.value)
                        .orderBy("episodeNo")
                        .snapshots(),
                    builder: (context, eSnapshot) {
                      if (!eSnapshot.hasData) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: LinearProgressIndicator(
                              color: kButtonColor,
                              backgroundColor: kWhiteColor.withValues(alpha: 0.1)),
                        );
                      }
                      List<DocumentSnapshot> episodeList = eSnapshot.data!.docs;
                      if (eSnapshot.hasData && episodeList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 25),
                            child: Text("No episodes yet!",
                                textAlign: TextAlign.center,
                                style: fontBody(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600)),
                          ),
                        );
                      }
                      return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => GestureDetector(
                                onTap: () {
                                  Get.offNamed("/watch", parameters: {
                                    "uid": uid,
                                    "vid": vid,
                                    "type": type,
                                    "section": "series",
                                    "episodeID": episodeList[index].id,
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: kWhiteColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: CachedNetworkImage(
                                                    imageUrl: episodeList[index]
                                                        ['thumbnail'],
                                                    placeholder: (c, s) =>
                                                        ColoredBox(
                                                            color: kWhiteColor
                                                                .withValues(
                                                                    alpha: 0.1)),
                                                    height: 30.w * 2 / 3,
                                                    width: 30.w,
                                                    fit: BoxFit.cover),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${episodeList[index]['episodeNo']}. ${episodeList[index]['episodeName']}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            customTextStyleBody(
                                                                fontSize: 17.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        DateFormat(
                                                                "dd MMMM yyyy")
                                                            .format(episodeList[
                                                                        index][
                                                                    'releaseDate']
                                                                .toDate()),
                                                        style:
                                                            customTextStyleBody(
                                                                fontSize: 15.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                      ),
                                                      Text(
                                                        "Duration: ${episodeList[index]['duration']}",
                                                        style:
                                                            customTextStyleBody(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          if (episodeList[index]
                                                  ["episodeDescription"]
                                              .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              child: ReadMoreText(
                                                episodeList[index]
                                                    ["episodeDescription"],
                                                trimLines: 2,
                                                colorClickableText:
                                                    kPrimaryColor,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText: 'Show more',
                                                trimExpandedText: 'Show less',
                                                style: customTextStyleBody(
                                                    fontSize: 16.5.sp),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          separatorBuilder: (context, i) =>
                              const Divider(color: Colors.grey, height: 40),
                          itemCount: episodeList.length);
                    }),
              ),
            ),
          ],
        ),
      ),
    ),
    backgroundColor: kBlackColor.withValues(alpha: 0.5),
    barrierColor: Colors.white12,
    enableDrag: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
  );
}

void openEpisodeEdit({required String uid, required String vid}) {
  Get.back();
  RxInt selectedSeasonIndex = 1.obs;
  Get.bottomSheet(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: 70.h,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(4),
                    decoration: const ShapeDecoration(
                        color: Colors.white12, shape: CircleBorder()),
                    child: const Icon(Icons.close),
                  ),
                ),
                Text("Select Episode",
                    style: fontHeading(
                        fontSize: 18.sp, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      Get.off(() => AddEpisode(uid: uid, vid: vid)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: kWhiteColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    shape: const StadiumBorder(),
                  ),
                  child:
                      Text("Add Episode", style: fontButton(fontSize: 14.5.sp)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 45,
              child: FutureBuilder<DocumentSnapshot>(
                  future: videosCollection.doc(vid).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemCount: snapshot.data!['seasons'],
                      itemBuilder: (context, index) {
                        return Obx(
                          () => FilterChip(
                            backgroundColor: kWhiteColor.withValues(alpha: 0.1),
                            selectedColor: kButtonColor,
                            label: Text("Season ${index + 1}",
                                style: fontButton(fontSize: 15.sp)),
                            selected: (index + 1) == selectedSeasonIndex.value,
                            onSelected: (selected) {
                              selectedSeasonIndex.value = index + 1;
                            },
                          ),
                        );
                      },
                    );
                  }),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(
                () => StreamBuilder<QuerySnapshot>(
                    stream: videosCollection
                        .doc(vid)
                        .collection("episodes")
                        .where("seasonNo", isEqualTo: selectedSeasonIndex.value)
                        .orderBy("episodeNo")
                        .snapshots(),
                    builder: (context, eSnapshot) {
                      if (!eSnapshot.hasData) {
                        return LinearProgressIndicator(
                            color: kPrimaryColor,
                            backgroundColor: kWhiteColor.withValues(alpha: 0.1));
                      }
                      List<DocumentSnapshot> episodeList = eSnapshot.data!.docs;
                      if (eSnapshot.hasData && episodeList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 25),
                            child: Text("No episodes yet!",
                                textAlign: TextAlign.center,
                                style: fontBody(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600)),
                          ),
                        );
                      }
                      return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => GestureDetector(
                                onTap: () => Get.off(() => EditEpisode(
                                    uid: uid,
                                    vid: vid,
                                    episodeID: episodeList[index].id)),
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: kWhiteColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: CachedNetworkImage(
                                                    imageUrl: episodeList[index]
                                                        ['thumbnail'],
                                                    placeholder: (c, s) =>
                                                        ColoredBox(
                                                            color: kWhiteColor
                                                                .withValues(
                                                                    alpha: 0.1)),
                                                    height: 30.w * 2 / 3,
                                                    width: 30.w,
                                                    fit: BoxFit.cover),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${episodeList[index]['episodeNo']}. ${episodeList[index]['episodeName']}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            customTextStyleBody(
                                                                fontSize:
                                                                    16.5.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        "Released on: ${DateFormat("dd MMMM yyyy").format(episodeList[index]['releaseDate'].toDate())}",
                                                        style:
                                                            customTextStyleBody(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                      ),
                                                      Text(
                                                        "Duration: ${episodeList[index]['duration']}",
                                                        style:
                                                            customTextStyleBody(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          ReadMoreText(
                                            episodeList[index]
                                                ["episodeDescription"],
                                            trimLines: 2,
                                            colorClickableText: kPrimaryColor,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'Show more',
                                            trimExpandedText: 'Show less',
                                            style: customTextStyleBody(
                                                fontSize: 16.5.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          separatorBuilder: (context, i) =>
                              const Divider(color: Colors.grey, height: 40),
                          itemCount: episodeList.length);
                    }),
              ),
            ),
          ],
        ),
      ),
    ),
    backgroundColor: kBlackColor.withValues(alpha: 0.5),
    barrierColor: Colors.white12,
    enableDrag: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
  );
}
