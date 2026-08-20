part of 'watch_button.dart';

extension _WatchButtonStateExt3 on _WatchButtonState {
  Widget buildMain(BuildContext context) {
    return widget.type == "FREE"
        ? TextButton(
            onPressed: () {
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

              openEpisodeList(
                  title: widget.title,
                  uid: widget.uid,
                  vid: widget.vid,
                  type: widget.type);
            },
            style: widget.isSmall
                ? TextButton.styleFrom(
                    foregroundColor: kWhiteColor,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    backgroundColor: kStreamPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  )
                : TextButton.styleFrom(
                    backgroundColor: kButtonColor,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
            child: Text(widget.section == "series" ? "Episodes" : "Watch Now",
                style: widget.isSmall
                    ? customTextStyleBody(
                        fontSize: 14.sp, fontWeight: FontWeight.w800)
                    : customTextStyleBody(
                        fontSize: 16.sp, fontWeight: FontWeight.w600)),
          )
        : widget.type == "RENT"
            ? StreamBuilder<DocumentSnapshot>(
                stream: usersCollection
                    .doc(widget.uid)
                    .collection("purchases")
                    .doc(widget.vid)
                    .snapshots(),
                builder: (context, psnapshot) {
                  String btnText =
                      "Rent for ${widget.pricing["validity"]} days";
                  bool isPurchased = false;
                  if (!psnapshot.hasData) {
                    isPurchased = false;
                    btnText = "Rent for ${widget.pricing["validity"]} days";
                  }

                  if (psnapshot.hasData && psnapshot.data!.exists) {
                    DateTime validity = DateTime.parse(
                        psnapshot.data!['validity'].toDate().toString());
                    if (!validity.difference(DateTime.now()).isNegative) {
                      btnText =
                          widget.section == "movies" ? "Watch Now" : "Episodes";
                      isPurchased = true;
                    } else {
                      btnText = "Rent for ${widget.pricing["validity"]} days";
                      isPurchased = false;
                    }
                  }

                  return widget.isSmall
                      ? TextButton(
                          onPressed: () {
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

                            openEpisodeList(
                                title: widget.title,
                                uid: widget.uid,
                                vid: widget.vid,
                                type: widget.type);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: kWhiteColor,
                            backgroundColor: kStreamPrimaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(btnText,
                              style: customTextStyleBody(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700)),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextButton(
                              onPressed: () {
                                if (!isPurchased) {
                                  Get.find<PurchaseService>().makePayment(
                                      amount:
                                          widget.pricing["amount"].toDouble(),
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

                                openEpisodeList(
                                    title: widget.title,
                                    uid: widget.uid,
                                    vid: widget.vid,
                                    type: widget.type);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: kButtonColor,
                                shape: const StadiumBorder(),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: Text(btnText,
                                  style: customTextStyleBody(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        );
                })
            : StreamBuilder<DocumentSnapshot>(
                stream: usersCollection.doc(widget.uid).snapshots(),
                builder: (context, usnapshot) {
                  String btnText = "Subscribe";
                  bool isPurchased = false;
                  if (!usnapshot.hasData) {
                    isPurchased = false;
                    btnText = "Subscribe";
                  }

                  if (usnapshot.hasData && usnapshot.data!.exists) {
                    DateTime validity = DateTime.parse(usnapshot
                        .data!['subscriptionDuration']
                        .toDate()
                        .toString());
                    if (!validity.difference(DateTime.now()).isNegative) {
                      btnText =
                          widget.section == "movies" ? "Watch Now" : "Episodes";
                      isPurchased = true;
                    }
                  }

                  return widget.isSmall
                      ? TextButton(
                          onPressed: () {
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

                            openEpisodeList(
                                title: widget.title,
                                uid: widget.uid,
                                vid: widget.vid,
                                type: widget.type);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: kWhiteColor,
                            backgroundColor: kStreamPrimaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(btnText,
                              style: customTextStyleBody(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700)),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextButton(
                              onPressed: () {
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

                                openEpisodeList(
                                    title: widget.title,
                                    uid: widget.uid,
                                    vid: widget.vid,
                                    type: widget.type);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: kButtonColor,
                                shape: const StadiumBorder(),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: Text(btnText,
                                  style: customTextStyleBody(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        );
                });
  }
}
