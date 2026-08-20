import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/views/withdraw.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../services/ads_service.dart';
import '../services/user_service.dart';
import 'package:boxalltv/utils/formatting.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';

part 'wallet_ext3.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  final box = GetStorage();

  bool rewardEarnedForSharing = false;

  DateTime today = DateTime.now();
  List<DateTime> to7Days = [];
  List<String> checkInDates = [];

  fetchCheckInDates() async {
    for (DateTime date in to7Days) {
      DocumentSnapshot checkInDoc = await usersCollection
          .doc(uid)
          .collection("checkIn")
          .doc(DateFormat("dd-MM-yyyy").format(date))
          .get();

      if (checkInDoc.exists) {
        checkInDates.add(checkInDoc.id);
      }
    }

    setState(() {});
  }

  fetchUserCheckIn() async {
    String checkInFirstDate = box.read("checkInFirstDate") ?? "";
    String checkInLastDate = box.read("checkInLastDate") ?? "";

    if (checkInLastDate.isEmpty || checkInFirstDate.isEmpty) {
      box.write("checkInFirstDate", today.toIso8601String());
      checkInFirstDate = today.toIso8601String();
      box.write("checkInLastDate",
          today.add(const Duration(days: 6)).toIso8601String());
    } else {
      if (today.isAfter(DateTime.parse(checkInLastDate))) {
        box.write("checkInFirstDate", today.toIso8601String());
        checkInFirstDate = today.toIso8601String();
        box.write("checkInLastDate",
            today.add(const Duration(days: 6)).toIso8601String());
      }
    }

    to7Days = List.generate(7,
        (index) => DateTime.parse(checkInFirstDate).add(Duration(days: index)));
    setState(() {});

    fetchCheckInDates();
  }

  openWithdrawSheet(BottomTabController btController) async {
    DocumentSnapshot generalDoc =
        await generalCollection.doc("5eAxTtCgFCYlm0Z131mt").get();
    double coinsValuation = generalDoc["coinsValuation"].toDouble();
    double minWithdraw = generalDoc["minWithdraw"].toDouble();

    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Withdraw balance",
                style:
                    fontBody(fontSize: 17.sp, color: const Color(0xfff71735))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: RichText(
                text: TextSpan(
                  text:
                      "\$${(btController.userData["wallet"] * coinsValuation).toStringAsFixed(2)}",
                  style: fontBody(
                      fontSize: 24.sp,
                      color: kWhiteColor,
                      fontWeight: FontWeight.w400),
                  children: [
                    TextSpan(
                      text:
                          " (${btController.userData["wallet"].toStringAsFixed(2)} coins)",
                      style: fontBody(
                          fontSize: 18.sp,
                          color: kWhiteColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            Text("1 coin = \$$coinsValuation",
                style: fontBody(
                    fontSize: 16.sp, color: kWhiteColor.withValues(alpha: 0.7))),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if ((btController.userData["wallet"] * coinsValuation) <
                    minWithdraw) {
                  customSnackBar(
                      text: "Minimum withdrawal amount is \$$minWithdraw");
                  return;
                }
                Get.off(() => Withdraw(
                    amount: btController.userData["wallet"] * coinsValuation,
                    minWithdraw: minWithdraw,
                    coinsValuation: coinsValuation));
              },
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xffdb3445), Color(0xfff71735)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text("Withdraw balance",
                    style: fontBody(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: kWhiteColor)),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                if (btController.userData["subscribed"]) {
                  customSnackBar(text: "Already subscribed");
                  return;
                }

                if (btController.userData["wallet"] < 5 / coinsValuation) {
                  customSnackBar(text: "Insufficient balance");
                  return;
                }

                Get.back();
                Get.dialog(customCircularProgress(strokeColor: kButtonColor),
                    barrierDismissible: false);
                await usersCollection.doc(uid).update({
                  "wallet": FieldValue.increment((5 / coinsValuation) * -1),
                });
                UserService.instance.subscribeUser(uid: uid, days: 28);
              },
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      kWhiteColor.withValues(alpha: 0.05),
                      kWhiteColor.withValues(alpha: 0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text("Buy subscription for \$5",
                    style: fontBody(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: kWhiteColor)),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: kGreyColor2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
    );
  }

  @override
  void initState() {
    fetchUserCheckIn();
    setState(() {
      rewardEarnedForSharing = box.read("shareRewardEarned") ?? false;
    });
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return buildMain(context);
  }
}
