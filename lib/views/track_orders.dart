import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TrackOrders extends StatefulWidget {
  final String uid;
  const TrackOrders({super.key, required this.uid});

  @override
  State<TrackOrders> createState() => _TrackOrdersState();
}

class _TrackOrdersState extends State<TrackOrders> {
  cancelOrder(DocumentSnapshot snapshot) {
    if (snapshot["shipped"]["status"]) {
      customSnackBar(text: "Cannot cancel this order after being shipped");
      return;
    }

    Get.defaultDialog(
        title: "Cancel Order",
        titleStyle: fontHeading(
            fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
        content: Text(
          "Are you sure you want to cancel this order?",
          style: fontBody(),
          textAlign: TextAlign.center,
        ),
        barrierDismissible: false,
        backgroundColor: kGreyColor2,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: kBlackColor,
              shape: const StadiumBorder(),
              foregroundColor: kWhiteColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("No",
                style:
                    fontButton(fontWeight: FontWeight.w600, fontSize: 16.sp)),
          ),
          TextButton(
            onPressed: () async {
              snapshot.reference.update({
                "cancelled": {
                  "status": true,
                  "date": DateTime.now(),
                }
              });
              customSnackBar(text: "Order cancelled successfully");
              Get.back();
            },
            style: TextButton.styleFrom(
              backgroundColor: kButtonColor,
              shape: const StadiumBorder(),
              foregroundColor: kWhiteColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
            child: Text("Cancel",
                style: customTextStyleBody(
                    fontWeight: FontWeight.w600, fontSize: 16.sp)),
          ),
        ]);
  }

  openTrackingDetails(DocumentSnapshot snapshot) {
    Get.bottomSheet(
      SizedBox(
        height: context.height / 1.5,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          children: [
            Text("Status",
                style: fontBody(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            TimelineTile(
              nodeAlign: TimelineNodeAlign.start,
              contents: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  tileColor: kPrimaryColor.withValues(alpha: 0.3),
                  title: Text("Order placed", style: fontHeading()),
                  subtitle: Text(DateFormat("dd/MM/yyyy")
                      .format(snapshot['orderPlaced']["date"].toDate())),
                ),
              ),
              node: const TimelineNode(
                indicator: DotIndicator(
                  color: kPrimaryColor,
                  size: 30,
                  child: Icon(Remix.check_line, color: Colors.white),
                ),
                startConnector: SolidLineConnector(color: kBlackColor),
                endConnector: SolidLineConnector(color: kPrimaryColor),
              ),
            ),
            TimelineTile(
              nodeAlign: TimelineNodeAlign.start,
              contents: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  tileColor: snapshot['shipped']["status"]
                      ? kPrimaryColor.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.1),
                  title: Text("Order Confirmed", style: fontHeading()),
                  subtitle: Text(snapshot['shipped']["date"] != null
                      ? "Will be delivered by ${DateFormat("dd/MM/yyyy").format(snapshot['shipped']["date"].toDate())}"
                      : "Usually gets shipped within 2-3 days"),
                ),
              ),
              node: TimelineNode(
                indicator: DotIndicator(
                  color: snapshot['shipped']["status"]
                      ? kPrimaryColor
                      : Colors.grey,
                  size: 30,
                  child: Icon(
                      snapshot['shipped']["status"]
                          ? Remix.check_line
                          : Remix.time_line,
                      color: Colors.white),
                ),
                startConnector: const SolidLineConnector(color: kPrimaryColor),
                endConnector: const SolidLineConnector(color: kPrimaryColor),
              ),
            ),
            TimelineTile(
              nodeAlign: TimelineNodeAlign.start,
              contents: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  tileColor: snapshot['outForDelivery']["status"]
                      ? kPrimaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  title: Text("Out for Delivery", style: fontHeading()),
                  subtitle: Text(snapshot['outForDelivery']["date"] != null
                      ? "Will reach to you by end of today"
                      : "Pending"),
                ),
              ),
              node: TimelineNode(
                indicator: DotIndicator(
                  color: snapshot['outForDelivery']["status"]
                      ? kPrimaryColor
                      : Colors.grey,
                  size: 30,
                  child: Icon(
                      snapshot['outForDelivery']["status"]
                          ? Remix.check_line
                          : Remix.time_line,
                      color: Colors.white),
                ),
                startConnector: const SolidLineConnector(color: kPrimaryColor),
                endConnector: const SolidLineConnector(color: kPrimaryColor),
              ),
            ),
            TimelineTile(
              nodeAlign: TimelineNodeAlign.start,
              contents: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  tileColor: snapshot['delivered']["status"]
                      ? kPrimaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  title: Text("Delivered", style: fontHeading()),
                  subtitle: Text(snapshot['delivered']["date"] != null
                      ? "Delivered"
                      : "Pending"),
                ),
              ),
              node: TimelineNode(
                indicator: DotIndicator(
                  color: snapshot['delivered']["status"]
                      ? kPrimaryColor
                      : Colors.grey,
                  size: 30,
                  child: Icon(
                      snapshot['delivered']["status"]
                          ? Remix.check_line
                          : Remix.time_line,
                      color: Colors.white),
                ),
                startConnector: const SolidLineConnector(color: kPrimaryColor),
                endConnector: const SolidLineConnector(color: kBlackColor),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kButtonColor,
                foregroundColor: kWhiteColor,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
              child: Text("Close",
                  style:
                      fontButton(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: kBlackColor,
      barrierColor: kWhiteColor.withValues(alpha: 0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Orders'),
      ),
      body: FirestoreListView(
        loadingBuilder: (context) =>
            progressIndicator(loadingText: "Loading Orders..."),
        emptyBuilder: (context) => Text("No Orders Found",
            style: fontBody(fontSize: 18.sp, fontWeight: FontWeight.w500)),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        query: ordersCollection
            .where("userID", isEqualTo: widget.uid)
            .orderBy("purchasedAt", descending: true),
        itemBuilder: (context, snapshot) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: kGreyColor2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    DateFormat("dd/MM/yyyy")
                        .format(snapshot["purchasedAt"].toDate()),
                    style:
                        fontBody(fontSize: 18.sp, fontWeight: FontWeight.w500)),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 15),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: kBlackColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("ORD.${snapshot.id}",
                      style: fontBody(
                          fontSize: 15.sp, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return FutureBuilder<DocumentSnapshot>(
                          future: videosCollection
                              .doc(snapshot["cartItems"][index]["vid"])
                              .collection("products")
                              .doc(snapshot["cartItems"][index]["productID"])
                              .get(),
                          builder: (context, prodSnap) {
                            if (!prodSnap.hasData) return const SizedBox();
                            DocumentSnapshot product = prodSnap.data!;
                            if (prodSnap.hasData && !product.exists) {
                              return const SizedBox();
                            }

                            return Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: kGreyColor2,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: product["image"],
                                      placeholder: (context, url) =>
                                          const ColoredBox(color: kBlackColor),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                      product["name"] +
                                          " x${snapshot["cartItems"][index]["count"]}",
                                      maxLines: 3,
                                      style: fontBody(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            );
                          });
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemCount: snapshot["cartItems"].length,
                  ),
                ),
                const Divider(color: kBlackColor, thickness: 5),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order Total:",
                        style: fontBody(
                            fontSize: 16.sp, fontWeight: FontWeight.w500)),
                    Text("\$${snapshot["totalAmountPaid"]}",
                        style: fontBody(
                            fontSize: 16.sp, fontWeight: FontWeight.w400))
                  ],
                ),
                const SizedBox(height: 10),
                snapshot["cancelled"]["status"]
                    ? Text(
                        "Order cancelled on ${DateFormat("dd/MM/yyyy, HH:mm").format(snapshot["cancelled"]["date"].toDate())}",
                        style: fontBody(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: kButtonColor),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => cancelOrder(snapshot),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kButtonColor,
                                  foregroundColor: kWhiteColor,
                                  elevation: 0),
                              child: Text("Cancel",
                                  style: fontButton(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => openTrackingDetails(snapshot),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: kWhiteColor,
                                  elevation: 0),
                              child: Text("Track Package",
                                  style: fontButton(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
