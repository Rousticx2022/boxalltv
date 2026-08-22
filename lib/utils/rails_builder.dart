import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:boxalltv/widgets/watch_button.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'ui_widgets.dart';
import 'placeholder_rails.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'collections.dart';
import 'container_builder.dart';
import 'styles.dart';
import 'package:flutter/material.dart';

part 'rails_builder_ext2.dart';

class RailsBuilder {
  final String uid;
  RailsBuilder({required this.uid});
  FutureBuilder<QuerySnapshot<Object?>> buildCarousel() {
    return FutureBuilder<QuerySnapshot>(
      future: videosCollection
          .where("active", isEqualTo: true)
          .where("isCarousel", isEqualTo: true)
          .orderBy("carouselOrder")
          .limit(5)
          .get(),
      builder: (context, bannerSnapshot) {
        if (!bannerSnapshot.hasData) {
          return SizedBox(
            height: 240,
            child: customCircularProgress(strokeColor: kPrimaryColor),
          );
        }
        return CarouselSlider(
          items: bannerSnapshot.data!.docs
              .map(
                (item) => GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      "/details",
                      parameters: {"uid": uid, "vid": item.id},
                    );
                  },
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: item['banner'],
                        placeholder: (context, url) => ColoredBox(
                          color: kWhiteColor.withValues(alpha: 0.1),
                        ),
                        errorWidget: (context, url, error) => ColoredBox(
                          color: kWhiteColor.withValues(alpha: 0.1),
                        ),
                        height: Get.width * (2 / 3),
                        width: Get.width,
                        fit: BoxFit.fill,
                      ),
                      Positioned.fill(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Container()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: usersCollection
                                        .doc(uid)
                                        .collection("watchlist")
                                        .doc(item.id)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      bool exists = false;
                                      if (!snapshot.hasData) {
                                        exists = false;
                                      }
                                      if (snapshot.hasData) {
                                        exists = snapshot.data!.exists;
                                      }
                                      return TextButton.icon(
                                        onPressed: () async {
                                          if (exists) {
                                            await usersCollection
                                                .doc(uid)
                                                .collection("watchlist")
                                                .doc(item.id)
                                                .delete();
                                          } else {
                                            await usersCollection
                                                .doc(uid)
                                                .collection("watchlist")
                                                .doc(item.id)
                                                .set({
                                                  "addedAt": DateTime.now(),
                                                  "poster": item["poster"],
                                                  "title": item["title"],
                                                  "type": item["type"],
                                                  "section": item["section"],
                                                });
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: kBlackColor,
                                          backgroundColor: kWhiteColor
                                              .withValues(alpha: 0.7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        icon: exists
                                            ? Icon(
                                                Icons.favorite,
                                                size: 15.sp,
                                                color: kButtonColor,
                                              )
                                            : Icon(
                                                Icons.add,
                                                size: 15.sp,
                                                color: kBlackColor,
                                              ),
                                        label: Text(
                                          "Watchlist",
                                          style: customTextStyleBody(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: kBlackColor,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  WatchButton(
                                    vid: item.id,
                                    uid: uid,
                                    pricing: item['pricing'],
                                    title: item['title'],
                                    type: item['type'],
                                    section: item['section'],
                                    isSmall: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          options: CarouselOptions(
            autoPlay: true,
            viewportFraction: 1,
            enlargeCenterPage: true,
            aspectRatio: context.width / (context.width * (2 / 3)),
            autoPlayInterval: const Duration(seconds: 10),
            autoPlayCurve: Curves.fastLinearToSlowEaseIn,
            autoPlayAnimationDuration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget buildTrending() {
    return StreamBuilder<QuerySnapshot>(
      stream: videosCollection
          .where("active", isEqualTo: true)
          .orderBy("trending")
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return PlaceholderRails.instance.buildBannerPlaceholder(context);
        }
        List<DocumentSnapshot> data = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Trending", style: fontBody(fontSize: 17.sp)),
                  data.length > 7
                      ? TextButton(
                          onPressed: () => Get.toNamed(
                            "/view_more/Trending",
                            parameters: {"uid": uid},
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).iconTheme.color,
                            backgroundColor: kBlackColor,
                          ),
                          child: const Text("More"),
                        )
                      : const SizedBox(height: 45),
                ],
              ),
              SizedBox(
                height: 20.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ContainerBuilder(
                      uid: uid,
                    ).videoContainer(context, data[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildMostPopular() {
    return StreamBuilder<QuerySnapshot>(
      stream: videosCollection
          .where("active", isEqualTo: true)
          .orderBy("popularity", descending: true)
          .limit(8)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return PlaceholderRails.instance.buildBannerPlaceholder(context);
        }
        List<DocumentSnapshot> data = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Most Popular", style: fontBody(fontSize: 17.sp)),
                  data.length > 7
                      ? TextButton(
                          onPressed: () => Get.toNamed(
                            "/view_more/Most Popular",
                            parameters: {"uid": uid},
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).iconTheme.color,
                            backgroundColor: kBlackColor,
                          ),
                          child: const Text("More"),
                        )
                      : const SizedBox(height: 45),
                ],
              ),
              SizedBox(
                height: 20.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ContainerBuilder(
                      uid: uid,
                    ).videoContainer(context, data[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildByYear(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: videosCollection
          .where("active", isEqualTo: true)
          .orderBy("views", descending: true)
          .limit(8)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return PlaceholderRails.instance.buildBannerPlaceholder(context);
        }
        List<DocumentSnapshot> data = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Most Viewed",
                    style: customTextStyleHeadline(fontSize: 18),
                  ),
                  data.length > 7
                      ? TextButton(
                          onPressed: () => Get.toNamed(
                            "/view_more/Most Viewed",
                            parameters: {"uid": uid},
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).iconTheme.color,
                            backgroundColor: kBlackColor,
                          ),
                          child: const Text("More"),
                        )
                      : const SizedBox(height: 45),
                ],
              ),
              SizedBox(
                height: 144,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ContainerBuilder(
                      uid: uid,
                    ).videoContainer(context, data[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildRecommended(List recommendations) {
    return recommendations.isNotEmpty
        ? StreamBuilder<QuerySnapshot>(
            stream: videosCollection
                .where("active", isEqualTo: true)
                .where("genres", arrayContainsAny: recommendations)
                .orderBy("popularity", descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return PlaceholderRails.instance.buildBannerPlaceholder(
                  context,
                );
              }
              if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                return Container();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Recommended", style: fontBody(fontSize: 17.sp)),
                        const SizedBox(height: 45),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ContainerBuilder(
                            uid: uid,
                          ).videoContainer(context, snapshot.data!.docs[index]);
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(width: 10),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : Container();
  }
}
