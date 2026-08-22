import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:numeral/numeral.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';

class ChatTab extends StatefulWidget {
  final String uid;
  const ChatTab({super.key, required this.uid});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: usersCollection
          .doc(widget.uid)
          .collection("messages")
          .orderBy("lastMessageOn", descending: true),
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemBuilder: (context, snapshot) {
        return FutureBuilder<DocumentSnapshot>(
          future: usersCollection.doc(snapshot.id).get(),
          builder: (context, usnapshot) {
            if (!usnapshot.hasData) return const SizedBox.shrink();
            if (usnapshot.hasData && !usnapshot.data!.exists) {
              return const SizedBox.shrink();
            }
            DocumentSnapshot udata = usnapshot.data!;
            return ListTile(
              onTap: () => Get.toNamed(
                "/messages",
                parameters: {
                  "uid": widget.uid,
                  "fid": snapshot.id,
                  "chatID": snapshot["chatID"],
                },
              ),
              leading: Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: kBlackColor,
                  border: Border.all(
                    color: snapshot["unreadCount"] > 0
                        ? kSocialPrimaryColor
                        : kGreyColor2,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: udata["profileImage"],
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: RichText(
                text: TextSpan(
                  text: udata["name"],
                  style: fontBody(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(
                      text:
                          " • ${timeago.format(snapshot["lastMessageOn"].toDate())}",
                      style: fontBody(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: kWhiteColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                snapshot["lastMessage"],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: fontBody(fontSize: 15.sp, color: kWhiteColor),
              ),
              trailing: snapshot["unreadCount"] > 0
                  ? Text(
                      Numeral(
                        snapshot["unreadCount"],
                      ).format(fractionDigits: 2),
                      style: fontBody(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: kSocialPrimaryColor,
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
