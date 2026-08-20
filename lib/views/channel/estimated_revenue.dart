import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:numeral/numeral.dart';
import 'package:boxalltv/controllers/bank_details_controller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EstimatedRevenue extends StatefulWidget {
  final String uid;
  const EstimatedRevenue({super.key, required this.uid});

  @override
  State<EstimatedRevenue> createState() => _EstimatedRevenueState();
}

class _EstimatedRevenueState extends State<EstimatedRevenue> {
  late BankDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BankDetailsController(uid: widget.uid));
  }

  @override
  void dispose() {
    Get.delete<BankDetailsController>();
    super.dispose();
  }

  void modifyBankDetails() {
    controller.fetchBankData();
    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, kBlackColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(4),
                        decoration: const ShapeDecoration(
                            color: Colors.white12, shape: CircleBorder()),
                        child: const Icon(Icons.close),
                      ),
                    ),
                    Text("Banking Details",
                        style: fontHeading(
                            fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: controller.accountNameController,
                        keyboardType: TextInputType.text,
                        style: customTextStyleBody(
                            color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Account holder",
                          labelStyle: customTextStyleBody(
                              color: kWhiteColor, fontSize: 16.sp),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter account holder name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: controller.accountNumberController,
                        keyboardType: TextInputType.text,
                        style: customTextStyleBody(
                            color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Account number",
                          labelStyle: customTextStyleBody(
                              color: kWhiteColor, fontSize: 16.sp),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter account number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: controller.bankNameController,
                        keyboardType: TextInputType.text,
                        style: customTextStyleBody(
                            color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Bank name",
                          labelStyle: customTextStyleBody(
                              color: kWhiteColor, fontSize: 16.sp),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter bank name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: controller.branchNameController,
                        keyboardType: TextInputType.text,
                        style: customTextStyleBody(
                            color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Branch",
                          labelStyle: customTextStyleBody(
                              color: kWhiteColor, fontSize: 16.sp),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter branch";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: controller.swiftCodeController,
                        keyboardType: TextInputType.text,
                        style: customTextStyleBody(
                            color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Swift code",
                          labelStyle: customTextStyleBody(
                              color: kWhiteColor, fontSize: 16.sp),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter swift code";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () => controller.updateBankDetails(),
                        style: TextButton.styleFrom(
                            backgroundColor: kButtonColor,
                            foregroundColor: kWhiteColor,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: Text("Save",
                            style: fontButton(
                                fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: kBlackColor.withValues(alpha: 0.5),
      barrierColor: Colors.white12,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estimated Revenue"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: creatorsCollection.doc(widget.uid).snapshots(),
                builder: (context, snapshot) {
                  double generatedRevenue = 0;
                  if (!snapshot.hasData) {
                    generatedRevenue = 0;
                  }
                  if (snapshot.hasData && snapshot.data!.exists) {
                    generatedRevenue =
                        snapshot.data!["totalRevenue"].toDouble();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: kGreyColor2,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                            "\$${Numeral(generatedRevenue).format(fractionDigits: 2)}",
                            style: fontBody(
                                fontSize: 24.sp, fontWeight: FontWeight.w400)),
                        if (generatedRevenue < 100)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              "You can request withdraw once you reach \$100 in revenue",
                              style: fontBody(
                                  fontSize: 16.sp,
                                  color: kButtonColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        if (generatedRevenue >= 100)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              "You can now withdraw the maximum revenue available",
                              style: fontBody(
                                  fontSize: 16.sp,
                                  color: kWhiteColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        if (generatedRevenue >= 100)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                Get.defaultDialog(
                                    title: "Withdraw Revenue",
                                    titleStyle: fontHeading(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20.sp,
                                        color: kWhiteColor),
                                    content: Text(
                                      "Are you sure you want to withdraw your total revenue of \$$generatedRevenue?",
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 30),
                                        ),
                                        child: Text("Later",
                                            style: customTextStyleBody(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Get.back();
                                          await creatorsCollection
                                              .doc(widget.uid)
                                              .collection("withdraws")
                                              .add({
                                            "amount": generatedRevenue,
                                            "uid": widget.uid,
                                            "status": "pending",
                                            "date": DateTime.now(),
                                          });

                                          customSnackBar(
                                              text: "Withdrawal request sent");
                                          await creatorsCollection
                                              .doc(widget.uid)
                                              .update({
                                            "totalRevenue": 0,
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: kButtonColor,
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 30),
                                        ),
                                        child: Text("Yes",
                                            style: customTextStyleBody(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp)),
                                      ),
                                    ]);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kBlackColor,
                                  foregroundColor: kButtonColor,
                                  padding: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              child: Text("Withdraw",
                                  style: fontButton(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
            Text("Withdrawal History",
                style:
                    fontHeading(fontWeight: FontWeight.w500, fontSize: 17.sp)),
            Expanded(
              child: FirestoreListView(
                padding: const EdgeInsets.symmetric(vertical: 15),
                emptyBuilder: (C) => Center(
                  child: Text("No withdrawal done yet!",
                      style: fontBody(
                          fontWeight: FontWeight.w600, fontSize: 16.sp)),
                ),
                query: creatorsCollection
                    .doc(widget.uid)
                    .collection("withdraws")
                    .orderBy("date", descending: true),
                itemBuilder: (context, snapshot) {
                  return ListTile(
                    title: Text("\$${snapshot["amount"]}",
                        style: fontBody(
                            fontSize: 18.sp, fontWeight: FontWeight.w400)),
                    subtitle: Text(
                      DateFormat("dd//MM/yyy")
                          .format(snapshot["date"].toDate()),
                      style: fontBody(fontSize: 15.sp),
                    ),
                    trailing: Text(
                      "${snapshot["status"].toUpperCase()}",
                      style: fontBody(
                          fontSize: 15.sp,
                          color: snapshot["status"] == "pending"
                              ? kButtonColor
                              : kWhiteColor,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: kBlackColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: TextButton(
            onPressed: () => modifyBankDetails(),
            style: TextButton.styleFrom(
                backgroundColor: kButtonColor,
                foregroundColor: kWhiteColor,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text("Your Banking Details",
                style:
                    fontButton(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
