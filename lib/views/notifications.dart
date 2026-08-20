import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/notifications_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';

class Notifications extends GetView<NotificationsController> {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: kWhiteColor),
            onPressed: () => Get.back()),
        actions: const [
          // IconButton(onPressed: () {}, icon: const Icon(Remix.notification_2_line), color: kWhiteColor),
        ],
      ),
      body: FirestoreListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        query: usersCollection
            .doc(controller.uid!)
            .collection("notifications")
            .orderBy("sentAt", descending: true),
        itemBuilder: (context, snapshot) {
          Widget? widget;

          switch (snapshot["type"]) {
            case "friend_request":
              widget = FutureBuilder<DocumentSnapshot>(
                  future: usersCollection.doc(snapshot["sentBy"]).get(),
                  builder: (context, usnap) {
                    if (!usnap.hasData) {
                      return ListTile(
                        tileColor: kBlackColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    }

                    DocumentSnapshot user = usnap.data!;

                    if (usnap.hasData && !user.exists) {
                      return const SizedBox.shrink();
                    }

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: kGreyColor2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            tileColor: kBlackColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            leading: Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: kBlackColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: user["profileImage"],
                                ),
                              ),
                            ),
                            title: Text(
                                "${user["name"]} ${snapshot["purpose"].toLowerCase()}",
                                style: customTextStyleHeadline(
                                    color: kWhiteColor,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                timeago.format(snapshot["sentAt"].toDate()),
                                style: customTextStyleBody(
                                    color: kWhiteColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.sp)),
                            trailing: IconButton(
                              onPressed: () => snapshot.reference.delete(),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        controller.rejectFriendRequest(
                                            snapshot["sentBy"], snapshot.id),
                                    style: TextButton.styleFrom(
                                        backgroundColor: kBlackColor),
                                    child: Text("Reject",
                                        style: customTextStyleBody(
                                            color: kWhiteColor,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        controller.acceptFriendRequest(
                                            snapshot["sentBy"], snapshot.id),
                                    style: TextButton.styleFrom(
                                        backgroundColor: kButtonColor),
                                    child: Text("Accept",
                                        style: customTextStyleBody(
                                            color: kBlackColor,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
              break;
            case "friend_request_accept":
              widget = FutureBuilder<DocumentSnapshot>(
                  future: usersCollection.doc(snapshot["sentBy"]).get(),
                  builder: (context, usnap) {
                    if (!usnap.hasData) {
                      return ListTile(
                        tileColor: kBlackColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    }

                    DocumentSnapshot user = usnap.data!;

                    if (usnap.hasData && !user.exists) {
                      return const SizedBox.shrink();
                    }

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: kGreyColor2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            leading: Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: kBlackColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: user["profileImage"],
                                ),
                              ),
                            ),
                            title: Text(
                                "${user["name"]} ${snapshot["purpose"].toLowerCase()}",
                                style: customTextStyleBody(
                                    color: kWhiteColor,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                timeago.format(snapshot["sentAt"].toDate()),
                                style: customTextStyleBody(
                                    color: kWhiteColor,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400)),
                            trailing: IconButton(
                              onPressed: () => snapshot.reference.delete(),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
              break;
            case "now_friends":
              widget = FutureBuilder<DocumentSnapshot>(
                  future: usersCollection.doc(snapshot["sentBy"]).get(),
                  builder: (context, usnap) {
                    if (!usnap.hasData) {
                      return ListTile(
                        tileColor: kBlackColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    }

                    DocumentSnapshot user = usnap.data!;

                    if (usnap.hasData && !user.exists) {
                      return const SizedBox.shrink();
                    }

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: kGreyColor2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            leading: Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: kBlackColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: user["profileImage"],
                                ),
                              ),
                            ),
                            title: Text(
                                "${user["name"]} ${snapshot["purpose"].toLowerCase()}",
                                style: customTextStyleBody(
                                    color: kWhiteColor,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                timeago.format(snapshot["sentAt"].toDate()),
                                style: customTextStyleBody(
                                    color: kWhiteColor,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400)),
                            trailing: IconButton(
                              onPressed: () => snapshot.reference.delete(),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: widget!,
          );
        },
      ),
    );
  }
}
