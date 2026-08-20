import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/episode_sheets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../utils/collections.dart';
import 'add_episode.dart';
import 'edit_series.dart';

class YourSeries extends StatefulWidget {
  final String uid;
  const YourSeries({super.key, required this.uid});

  @override
  State<YourSeries> createState() => _YourSeriesState();
}

class _YourSeriesState extends State<YourSeries> {
  void openEditOptions(String vid) {
    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
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
                  Text("Edit Series",
                      style: fontHeading(
                          fontSize: 18.sp, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 15),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit),
                title: const Text("Edit Series Details"),
                onTap: () => Get.to(
                    () => EditSeries(videoID: vid, uid: widget.uid),
                    transition: Transition.cupertino),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit),
                title: const Text("Edit Episodes"),
                onTap: () => openEpisodeEdit(uid: widget.uid, vid: vid),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add),
                title: const Text("Add Episode"),
                onTap: () => Get.off(
                    () => AddEpisode(uid: widget.uid, vid: vid),
                    transition: Transition.cupertino),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      backgroundColor: kBlackColor.withValues(alpha: 0.5),
      barrierColor: Colors.white12,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Series"),
      ),
      body: FirestoreListView(
        emptyBuilder: (context) => Center(
            child: Text("No series found",
                style: fontBody(fontSize: 18.sp, fontWeight: FontWeight.w600))),
        padding: const EdgeInsets.all(20.0),
        query: videosCollection
            .where('creatorID', isEqualTo: widget.uid)
            .where("section", isEqualTo: "series")
            .orderBy('title'),
        itemBuilder: (BuildContext context, DocumentSnapshot snapshot) {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  imageUrl: snapshot['banner'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(snapshot['title'],
                    style:
                        fontBody(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                subtitle: Text(snapshot['genres'].join(", "),
                    style: fontBody(
                        fontSize: 15.5.sp, fontWeight: FontWeight.w400)),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  // Expanded(
                  //   child: TextButton(
                  //     onPressed: () {},
                  //     style: TextButton.styleFrom(backgroundColor: kStreamPrimaryColor, foregroundColor: kWhiteColor),
                  //     child: Text("Stats", style: fontButton(fontSize: 17.sp)),
                  //   ),
                  // ),
                  // const SizedBox(width: 10.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () => openEditOptions(snapshot.id),
                      style: TextButton.styleFrom(
                          backgroundColor: kGreyColor2,
                          foregroundColor: kWhiteColor),
                      child: Text("Edit", style: fontButton(fontSize: 17.sp)),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        snapshot.reference
                            .update({"active": !snapshot["active"]});
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: kButtonColor,
                          foregroundColor: kWhiteColor),
                      child: Text(snapshot["active"] ? "Disable" : "Enable",
                          style: fontButton(fontSize: 17.sp)),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
