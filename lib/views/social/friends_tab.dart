import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/collections.dart';

class FriendsTab extends StatefulWidget {
  final String uid;
  const FriendsTab({super.key, required this.uid});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  Future<void> openChat(String fid) async {
    DocumentSnapshot snapshot = await usersCollection
        .doc(widget.uid)
        .collection("messages")
        .doc(fid)
        .get();
    if (snapshot.exists) {
      Get.toNamed("/messages", parameters: {
        "uid": widget.uid,
        "fid": fid,
        "chatID": snapshot["chatID"]
      });
    } else {
      var doc = await chatsCollection.add({
        "friends": [widget.uid, fid],
        "friendsFrom": DateTime.now(),
        "status": "normal",
      });
      DateTime now = DateTime.now();

      await usersCollection
          .doc(widget.uid)
          .collection("messages")
          .doc(fid)
          .set({
        "chatID": doc.id,
        "lastMessage": "Start a new chat",
        "unreadCount": 0,
        "lastMessageBy": "",
        "lastMessageOn": now,
        "status": "normal",
      });
      Get.toNamed("/messages",
          parameters: {"uid": widget.uid, "fid": fid, "chatID": doc.id});
      await usersCollection
          .doc(fid)
          .collection("messages")
          .doc(widget.uid)
          .set({
        "chatID": doc.id,
        "lastMessage": "Start a new chat",
        "unreadCount": 0,
        "lastMessageBy": "",
        "lastMessageOn": now,
        "status": "normal",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      query: usersCollection
          .doc(widget.uid)
          .collection("friends")
          .where("status", isEqualTo: "friends")
          .orderBy("addedAt", descending: true),
      itemBuilder: (context, snapshot) {
        return FutureBuilder<DocumentSnapshot>(
            future: usersCollection.doc(snapshot.id).get(),
            builder: (context, usnapshot) {
              if (!usnapshot.hasData) {
                return customCircularProgress(strokeColor: kSocialPrimaryColor);
              }

              DocumentSnapshot friend = usnapshot.data!;
              if (usnapshot.hasData && !friend.exists) {
                return const SizedBox();
              }
              return ListTile(
                onTap: () => Get.toNamed("/public_profile",
                    parameters: {"userID": friend.id}),
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: kBlackColor,
                    border: Border.all(color: kGreyColor2, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: friend["profileImage"],
                    ),
                  ),
                ),
                title: Text("${friend["name"]}",
                    style: fontBody(
                        color: kWhiteColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => openChat(friend.id),
                      style: TextButton.styleFrom(
                          backgroundColor: kGreyColor2,
                          foregroundColor: kSocialPrimaryColor),
                      child: Text("Chat",
                          style: fontBody(
                              color: kSocialPrimaryColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600)),
                    ),
                    // const SizedBox(width: 15),
                    // InkWell(
                    //   onTap: () {},
                    //   child: const Icon(Icons.more_vert, color: kWhiteColor),
                    // ),
                  ],
                ),
              );
            });
      },
    );
  }
}
