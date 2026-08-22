import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:readmore/readmore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timeago/timeago.dart' as time_ago;
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';

Widget commentBox(DocumentSnapshot commentData) =>
    FutureBuilder<DocumentSnapshot>(
      future: usersCollection.doc(commentData["commentator"]).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        DocumentSnapshot udata = snapshot.data!;
        if (snapshot.hasData && !udata.exists) {
          return const SizedBox.shrink();
        }
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: kWhiteColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: udata["profileImage"],
                fit: BoxFit.cover,
              ),
            ),
          ),
          minLeadingWidth: 0,
          title: Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                udata["name"],
                style: customTextStyleBody(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: kWhiteColor,
                ),
              ),
              Text(
                "•  ${time_ago.format(commentData["postedOn"].toDate())}",
                style: customTextStyleBody(
                  fontSize: 13.sp,
                  color: kSocialPrimaryColor,
                ),
              ),
            ],
          ),
          subtitle: ReadMoreText(
            commentData["comment"],
            trimLines: 2,
            style: customTextStyleBody(fontSize: 16.sp, color: kWhiteColor),
            colorClickableText: kWhiteColor,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'more',
            trimExpandedText: 'less',
          ),
        );
      },
    );
