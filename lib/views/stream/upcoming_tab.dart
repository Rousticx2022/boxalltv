import 'package:cached_network_image/cached_network_image.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../trailer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../utils/styles.dart';
import '../../utils/collections.dart';

class UpcomingTab extends StatefulWidget {
  final String uid;
  const UpcomingTab({super.key, required this.uid});

  @override
  _UpcomingTabState createState() => _UpcomingTabState();
}

class _UpcomingTabState extends State<UpcomingTab> {
  late Widget content;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: upcomingCollection
          .where("active", isEqualTo: true)
          .orderBy("releaseDate", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: customCircularProgress(
              strokeColor: Theme.of(context).primaryColor,
            ),
          );
        }
        List<DocumentSnapshot> upcomingList = snapshot.data!.docs;
        if (snapshot.hasData && upcomingList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/nothing.png", width: context.width / 2),
                Text(
                  "No upcoming shows",
                  style: customTextStyleBody(fontSize: 15.sp),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: upcomingList[index]['image'],
                      placeholder: (c, s) =>
                          ColoredBox(color: kWhiteColor.withValues(alpha: 0.1)),
                      fit: BoxFit.fill,
                      width: context.width,
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.all(5.0),
                      child: upcomingList[index]['trailer'] != null
                          ? TextButton.icon(
                              onPressed: () => Get.to(
                                () => Trailer(
                                  title: upcomingList[index]["title"],
                                  video: upcomingList[index]['trailer'],
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: kBlackColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(color: Colors.white),
                                ),
                              ),
                              icon: Icon(
                                Icons.play_circle_fill,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              label: Text(
                                "Trailer",
                                style: customTextStyleBody(
                                  color: kWhiteColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    upcomingList[index]["title"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: customTextStyleHeadline(fontSize: 22.sp),
                  ),
                ),
                Text(
                  "Releasing on: ${DateFormat.yMMMEd().format(upcomingList[index]["releaseDate"].toDate())}",
                  style: customTextStyleBody(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          separatorBuilder: (context, i) => const SizedBox(height: 10),
          itemCount: upcomingList.length,
        );
      },
    );
  }
}
