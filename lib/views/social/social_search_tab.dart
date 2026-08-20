import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/collections.dart';

class SocialSearchTab extends StatefulWidget {
  final String uid;
  const SocialSearchTab({super.key, required this.uid});

  @override
  State<SocialSearchTab> createState() => _SocialSearchTabState();
}

class _SocialSearchTabState extends State<SocialSearchTab> {
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextFormField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            keyboardType: TextInputType.text,
            style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
            decoration: InputDecoration(
              fillColor: Colors.white10,
              filled: true,
              prefixIcon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/search_icon.png", width: 5.w),
                ],
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              enabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              hintText: "Search people...",
              hintStyle: fontBody(color: kWhiteColor, fontSize: 16.sp),
            ),
          ),
          Expanded(
            child: FirestoreListView(
                pageSize: 5,
                query: usersCollection.orderBy("active"),
                itemBuilder: (context, snapshot) {
                  if (snapshot.id == widget.uid) return const SizedBox();

                  if (searchText.isNotEmpty &&
                      !snapshot["name"]
                          .contains(RegExp(searchText, caseSensitive: false))) {
                    return const SizedBox();
                  }

                  return GestureDetector(
                    onTap: () => Get.toNamed("/public_profile",
                        parameters: {"userID": snapshot.id}),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: kBlackColor,
                              border:
                                  Border.all(color: kGreyColor2, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                imageUrl: snapshot["profileImage"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot["name"],
                                    maxLines: 1,
                                    style: fontBody(
                                        color: kWhiteColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.sp)),
                                Text(
                                    snapshot["active"]
                                        ? "Active Now"
                                        : timeago.format(
                                            snapshot["lastSeen"].toDate()),
                                    maxLines: 1,
                                    style: fontBody(
                                        color: kWhiteColor, fontSize: 13.sp)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          StreamBuilder<DocumentSnapshot>(
                              stream: usersCollection
                                  .doc(widget.uid)
                                  .collection("friends")
                                  .doc(snapshot.id)
                                  .snapshots(),
                              builder: (context, fsnapshot) {
                                if (!fsnapshot.hasData) return const SizedBox();

                                DocumentSnapshot fdata = fsnapshot.data!;

                                if (fsnapshot.hasData && fdata.exists) {
                                  if (fdata["status"] == "friends") {
                                    return ElevatedButton(
                                      onPressed: () => openChat(snapshot.id),
                                      style: TextButton.styleFrom(
                                          backgroundColor: kGreyColor2,
                                          foregroundColor: kSocialPrimaryColor),
                                      child: Text("Chat",
                                          style: fontBody(
                                              color: kSocialPrimaryColor,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600)),
                                    );
                                  }
                                  return const SizedBox();
                                }
                                return ElevatedButton(
                                  onPressed: () async {
                                    customSnackBar(text: "Request sent");
                                    await usersCollection
                                        .doc(widget.uid)
                                        .collection("friends")
                                        .doc(snapshot.id)
                                        .set({
                                      "status": "requested",
                                      "addedAt": DateTime.now(),
                                    });

                                    http.Response response = await http.post(
                                      Uri.parse(
                                          "http://65.109.39.177:7110/send_notification"),
                                      body: jsonEncode({
                                        "title": "New friend request",
                                        "message":
                                            "${snapshot["name"]} send you a friend request",
                                        "uid": snapshot.id,
                                      }),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: kGreyColor2,
                                      foregroundColor: kSocialPrimaryColor),
                                  child: Text("Add",
                                      style: fontBody(
                                          color: kSocialPrimaryColor,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600)),
                                );
                              }),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  openChat(String fid) async {
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
}
