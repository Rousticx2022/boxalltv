import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../services/purchase_service.dart';
import '../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/episode_sheets.dart';
import '../utils/styles.dart';
import '../views/subscriptions.dart';

part 'watch_button_ext3.dart';

class WatchButton extends StatefulWidget {
  final String vid, uid, title, type, section;
  final bool isSmall;
  final Map pricing;
  const WatchButton({
    super.key,
    required this.vid,
    required this.uid,
    required this.pricing,
    required this.title,
    required this.type,
    required this.section,
    this.isSmall = false,
  });

  @override
  State<WatchButton> createState() => _WatchButtonState();
}

class _WatchButtonState extends State<WatchButton> {
  @override
  @override
  Widget build(BuildContext context) {
    return buildMain(context);
  }
}

class WatchWidget extends StatefulWidget {
  final String vid, uid, title, type, section, episodeID;
  final Map pricing;
  final Widget widget;
  const WatchWidget(
      {super.key,
      required this.vid,
      required this.uid,
      required this.pricing,
      required this.title,
      required this.type,
      required this.section,
      this.episodeID = "",
      required this.widget});

  @override
  State<WatchWidget> createState() => _WatchWidgetState();
}

class _WatchWidgetState extends State<WatchWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.type == "FREE"
        ? GestureDetector(
            onTap: () {
              if (widget.section == "movies") {
                Get.toNamed("/watch", parameters: {
                  "uid": widget.uid,
                  "vid": widget.vid,
                  "type": widget.type,
                  "section": widget.section,
                  "episodeID": "",
                });
                return;
              }
              Get.toNamed("/watch", parameters: {
                "uid": widget.uid,
                "vid": widget.vid,
                "type": widget.type,
                "section": widget.section,
                "episodeID": widget.episodeID.split("_")[1],
              });
            },
            child: widget.widget,
          )
        : widget.type == "RENT"
            ? StreamBuilder<DocumentSnapshot>(
                stream: usersCollection
                    .doc(widget.uid)
                    .collection("purchases")
                    .doc(widget.vid)
                    .snapshots(),
                builder: (context, psnapshot) {
                  bool isPurchased = false;
                  if (!psnapshot.hasData) {
                    isPurchased = false;
                  }

                  if (psnapshot.hasData && psnapshot.data!.exists) {
                    DateTime validity = DateTime.parse(
                        psnapshot.data!['validity'].toDate().toString());
                    if (!validity.difference(DateTime.now()).isNegative) {
                      isPurchased = true;
                    } else {
                      isPurchased = false;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      if (!isPurchased) {
                        Get.find<PurchaseService>().makePayment(
                            amount: widget.pricing["amount"].toDouble(),
                            uid: widget.uid,
                            vid: widget.vid,
                            validity: widget.pricing["validity"]);
                        return;
                      }
                      if (widget.section == "movies") {
                        Get.toNamed("/watch", parameters: {
                          "uid": widget.uid,
                          "vid": widget.vid,
                          "type": widget.type,
                          "section": widget.section,
                          "episodeID": "",
                        });
                        return;
                      }

                      Get.toNamed("/watch", parameters: {
                        "uid": widget.uid,
                        "vid": widget.vid,
                        "type": widget.type,
                        "section": widget.section,
                        "episodeID": widget.episodeID.split("_")[1],
                      });
                    },
                    child: widget.widget,
                  );
                })
            : StreamBuilder<DocumentSnapshot>(
                stream: usersCollection.doc(widget.uid).snapshots(),
                builder: (context, usnapshot) {
                  bool isPurchased = false;
                  if (!usnapshot.hasData) {
                    isPurchased = false;
                  }

                  if (usnapshot.hasData && usnapshot.data!.exists) {
                    DateTime validity = DateTime.parse(usnapshot
                        .data!['subscriptionDuration']
                        .toDate()
                        .toString());
                    if (!validity.difference(DateTime.now()).isNegative) {
                      isPurchased = true;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      if (!isPurchased) {
                        Get.to(() => Subscriptions(uid: widget.uid));
                        return;
                      }
                      if (widget.section == "movies") {
                        Get.toNamed("/watch", parameters: {
                          "uid": widget.uid,
                          "vid": widget.vid,
                          "type": widget.type,
                          "section": widget.section,
                          "episodeID": "",
                        });
                        return;
                      }
                      Get.toNamed("/watch", parameters: {
                        "uid": widget.uid,
                        "vid": widget.vid,
                        "type": widget.type,
                        "section": widget.section,
                        "episodeID": widget.episodeID.split("_")[1],
                      });
                    },
                    child: widget.widget,
                  );
                });
  }
}

class WatchSearchButton extends StatefulWidget {
  final String vid, uid, title, type, section, episodeID, startTime;
  final Map pricing;

  const WatchSearchButton(
      {super.key,
      required this.vid,
      required this.uid,
      required this.pricing,
      required this.title,
      required this.type,
      required this.section,
      this.episodeID = "",
      required this.startTime});

  @override
  State<WatchSearchButton> createState() => _WatchSearchButtonState();
}

class _WatchSearchButtonState extends State<WatchSearchButton> {
  @override
  Widget build(BuildContext context) {
    return widget.type == "FREE"
        ? TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              List startTime = widget.startTime.split(":");

              List secs = startTime[2].split(",");

              int milsec = (int.parse(startTime[0]) * 3600000) +
                  (int.parse(startTime[1]) * 60000) +
                  (int.parse(secs[0]) * 1000) +
                  int.parse(secs[1]);

              Get.toNamed("/watch", parameters: {
                "uid": widget.uid,
                "vid": widget.vid,
                "type": widget.type,
                "section": widget.section,
                "episodeID": widget.episodeID,
                "seek": (milsec * 1000).toString(),
              });
            },
            child: Text("Watch Now",
                style: customTextStyleBody(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kWhiteColor)),
          )
        : StreamBuilder<DocumentSnapshot>(
            stream: usersCollection
                .doc(widget.uid)
                .collection("purchases")
                .doc(widget.vid)
                .snapshots(),
            builder: (context, psnapshot) {
              bool isPurchased = false;
              if (!psnapshot.hasData) {
                isPurchased = false;
              }

              if (psnapshot.hasData && psnapshot.data!.exists) {
                DateTime validity = DateTime.parse(
                    psnapshot.data!['validity'].toDate().toString());
                if (!validity.difference(DateTime.now()).isNegative) {
                  isPurchased = true;
                } else {
                  isPurchased = false;
                }
              }

              return TextButton(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (!isPurchased) {
                    Get.find<PurchaseService>().makePayment(
                        amount: widget.pricing["amount"].toDouble(),
                        uid: widget.uid,
                        vid: widget.vid,
                        validity: widget.pricing["validity"]);
                    return;
                  }
                  List startTime = widget.startTime.split(":");

                  List secs = startTime[2].split(",");

                  int milsec = (int.parse(startTime[0]) * 3600000) +
                      (int.parse(startTime[1]) * 60000) +
                      (int.parse(secs[0]) * 1000) +
                      int.parse(secs[1]);

                  Get.toNamed("/watch", parameters: {
                    "uid": widget.uid,
                    "vid": widget.vid,
                    "type": widget.type,
                    "section": widget.section,
                    "episodeID": widget.episodeID,
                    "seek": (milsec * 1000).toString(),
                  });
                },
                child: Text(isPurchased ? "Watch Now" : "Purchase Now",
                    style: customTextStyleBody(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: kWhiteColor)),
              );
            });
  }
}
