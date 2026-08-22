/*
Company: Shader Bytes
Developed By: Pradeepta Bhattacharya
*/
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../widgets/watch_button.dart';
import 'collections.dart';
import 'ui_widgets.dart';

class ContainerBuilder {
  final String uid;
  ContainerBuilder({required this.uid});

  Widget videoContainer(BuildContext context, DocumentSnapshot document) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed("/details", parameters: {"uid": uid, "vid": document.id}),
      child: SizedBox(
        width: 20.h * 3 / 4,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: document['poster'],
                placeholder: (context, url) =>
                    Image.asset("assets/placeholder1.gif"),
                errorWidget: (context, url, error) =>
                    Image.asset("assets/placeholder1.gif"),
                width: 20.h * 3 / 3,
                height: 20.h,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              right: 3,
              top: 3,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: ShapeDecoration(
                  color: kWhiteColor,
                  shape: const CircleBorder(),
                  shadows: [
                    BoxShadow(
                      color: kGreyColor1.withValues(alpha: 0.3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  document['contentRating'],
                  style: fontBody(color: kBlackColor, fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget videoContainer2(
    BuildContext context,
    DocumentSnapshot vdata,
    DocumentSnapshot document,
  ) {
    return WatchWidget(
      uid: uid,
      vid: vdata.id,
      pricing: vdata["pricing"],
      title: vdata["title"],
      type: vdata["type"],
      section: vdata["section"],
      episodeID: document.id,
      widget: SizedBox(
        width: 20.h * 3 / 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: vdata['poster'],
                    placeholder: (context, url) =>
                        Image.asset("assets/placeholder1.gif"),
                    errorWidget: (context, url, error) =>
                        Image.asset("assets/placeholder1.gif"),
                    height: 20.h,
                    width: 20.h * 3 / 4,
                    fit: BoxFit.fill,
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                if (vdata["section"] == "series")
                  Positioned(
                    bottom: 5,
                    left: 5,
                    child: FutureBuilder<DocumentSnapshot>(
                      future: videosCollection
                          .doc(vdata.id)
                          .collection("episodes")
                          .doc(document["episodeID"])
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "S${snapshot.data!["seasonNo"]}•E${snapshot.data!["episodeNo"]}",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                shadows: <Shadow>[
                                  const Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 3.0,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${snapshot.data!["episodeName"]}",
                              maxLines: 1,
                              style: fontBody(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                shadows: <Shadow>[
                                  const Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 3.0,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: LinearProgressIndicator(
                minHeight: 2,
                value: document["position"] / document["duration"],
                color: Get.theme.primaryColor,
                backgroundColor: Colors.white24,
              ),
            ),
            Text(
              "${((document["duration"] - document["position"]) ~/ 60000000)}m remaining",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget videoContainerPortrait(
    BuildContext context,
    DocumentSnapshot document, {
    bool replace = false,
  }) {
    return GestureDetector(
      onTap: () => replace
          ? Get.offNamed(
              "/details",
              parameters: {"uid": uid, "vid": document.id},
            )
          : Get.toNamed(
              "/details",
              parameters: {"uid": uid, "vid": document.id},
            ),
      child: SizedBox(
        width: 20.h * 3 / 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: document['poster'],
                    placeholder: (context, url) =>
                        Image.asset("assets/placeholder2.gif"),
                    errorWidget: (context, url, error) =>
                        Image.asset("assets/placeholder2.gif"),
                    height: 20.h,
                    width: 20.h * 3 / 4,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: ShapeDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: const CircleBorder(),
                    ),
                    child: Text(
                      document['contentRating'],
                      style: fontBody(color: kBlackColor, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget videoGridContainer(BuildContext context, DocumentSnapshot document) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed("/details", parameters: {"uid": uid, "vid": document.id}),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: document['poster'],
              placeholder: (context, url) =>
                  Image.asset("assets/placeholder2.gif"),
              errorWidget: (context, url, error) =>
                  Image.asset("assets/placeholder2.gif"),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: ShapeDecoration(
                color: Theme.of(context).primaryColor,
                shape: const CircleBorder(),
              ),
              child: Text(
                document['contentRating'],
                style: fontBody(color: kBlackColor, fontSize: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
