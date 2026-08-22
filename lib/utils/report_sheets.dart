import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../utils/styles.dart';
import 'collections.dart';
import 'ui_widgets.dart';

void openTrendReelReport({required String reelID, required String uid}) {
  Get.bottomSheet(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kWhiteColor.withValues(alpha: 0.05),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 35,
                    width: 35,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.close, color: kReelsPrimaryColor),
                  ),
                ),
                Text(
                  "Report this Trend",
                  style: fontBody(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: reportTypesCollection.orderBy("order").get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return customCircularProgress(
                      strokeColor: kReelsPrimaryColor,
                    );
                  }

                  List<DocumentSnapshot> reports = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: reports.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Get.back();
                          Get.defaultDialog(
                            title: "Send Report",
                            backgroundColor: Colors.grey.shade900,
                            titleStyle: fontBody(
                              fontSize: 20,
                              color: kWhiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                            content: Text(
                              "You have marked this trend as `${reports[index]["title"]}`. Your report will be reviewed withing 48 hours.",
                              textAlign: TextAlign.center,
                              style: fontBody(
                                fontSize: 16,
                                color: kWhiteColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kBlackColor,
                                  foregroundColor: kWhiteColor,
                                  elevation: 0,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),
                                child: Text(
                                  "No",
                                  style: fontBody(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await reelsCollection.doc(reelID).update({
                                    "active": false,
                                    "deactivateReason": "UserReport",
                                  });
                                  Get.back();
                                  customSnackBar(
                                    text: "Report submitted successfully",
                                  );
                                  await reelsCollection
                                      .doc(reelID)
                                      .collection("reports")
                                      .add({
                                        "reportedBy": uid,
                                        "title": reports[index]["title"],
                                        "description":
                                            reports[index]["description"],
                                        "reportedAt": DateTime.now(),
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kReelsPrimaryColor,
                                  foregroundColor: kBlackColor,
                                  elevation: 0,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),
                                child: Text(
                                  "Send",
                                  style: fontBody(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        title: Text(
                          reports[index]["title"],
                          style: fontBody(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: kWhiteColor,
                          ),
                        ),
                        subtitle: Text(
                          reports[index]["description"],
                          style: fontBody(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: kWhiteColor,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward,
                          color: kWhiteColor,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    enableDrag: false,
  );
}
