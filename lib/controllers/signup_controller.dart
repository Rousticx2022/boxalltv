import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';
import '../utils/collections.dart';
import '../views/maintenance.dart';

class SignupController extends GetxController {
  var passwordVisible = false.obs, loading = false.obs;
  bool isAndroid = Platform.isAndroid, isTV = false;
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(),
      phoneController = TextEditingController(),
      zipcodeController = TextEditingController(),
      countryController = TextEditingController(),
      searchCountryController = TextEditingController(),
      searchZipcodeController = TextEditingController(),
      usernameController = TextEditingController(),
      codeController = TextEditingController(),
      passwordController = TextEditingController();
  final emailFocus = FocusNode(),
      passwordFocus = FocusNode(),
      signButtonFocus = FocusNode();
  RxString searchCountry = "".obs, searchZipcode = "".obs;

  List targetCountries = [];
  Rx selectedTargetCountry = "".obs;

  void togglePassword() {
    passwordVisible.value = !passwordVisible.value;
  }

  Future<void> fetchTargetCountries() async {
    QuerySnapshot countries =
        await targetCountriesCollection.orderBy("country").get();
    targetCountries = countries.docs;
    selectedTargetCountry.value = targetCountries.first["country"];
  }

  void emailPasswordSignup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    loading.value = true;
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((currentUser) async {
        String uid = currentUser.user!.uid;

        await currentUser.user!.sendEmailVerification();

        await usersCollection.doc(uid).set({
          "active": true,
          "createdAt": DateTime.now(),
          "email": emailController.text.toLowerCase(),
          "messageToken": "",
          "name": usernameController.text,
          "recommendations": [],
          "followers": 0,
          "following": 0,
          "lastCheckIn": null,
          "accountType": "freemium",
          "country": countryController.text,
          "phoneNumber": phoneController.text,
          "watchingNow": false,
          "phoneVerified": false,
          "subscribed": false,
          "zipcode": zipcodeController.text,
          "subscriptionDuration": DateTime.now(),
          "bankDetails": {
            "accountNumber": "",
            "accountName": "",
            "bankName": "",
            "branch": "",
            "swiftCode": "",
          },
          "profileImage":
              "https://firebasestorage.googleapis.com/v0/b/frame-f5635.appspot.com/o/noavatar.jpg?alt=media&token=e039fec3-ed48-4ef4-a2d1-73805eab4858",
        });

        DocumentSnapshot generalDoc =
            await generalCollection.doc("RCVdTHFlVIVCUjuiD1pm").get();

        customSnackBar(text: "Account creation successful");

        if (!generalDoc["isLive"] || !generalDoc["isUnderMaintenance"]) {
          Get.offAll(() => Maintenance(
              isLive: generalDoc["isLive"],
              isUnderMaintenance: generalDoc["isUnderMaintenance"]));
          return;
        }

        Get.offAllNamed("/bottom_tab",
            parameters: {"uid": currentUser.user!.uid});
      });
    } on FirebaseAuthException catch (e) {
      loading.value = false;
      if (e.code == 'email-already-in-use') {
        customSnackBar(text: "Account already exists");
      } else if (e.code == 'weak-password') {
        customSnackBar(text: "Weak Password");
      } else if (e.code == 'invalid-email') {
        customSnackBar(text: "Invalid email address");
      }
    }
  }

  void selectCountry() => Get.bottomSheet(
      StreamBuilder<QuerySnapshot>(
          stream: countriesCollection.orderBy("name").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return customCircularProgress(strokeColor: kPrimaryColor);
            }
            List<DocumentSnapshot> countries = snapshot.data!.docs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, kToolbarHeight, 15, 0),
                  child: Row(
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
                      Text("Select Countries",
                          style: fontHeading(
                              fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                  child: TextFormField(
                    controller: searchCountryController,
                    style: customTextStyleBody(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: kWhiteColor),
                    keyboardType: TextInputType.text,
                    onChanged: (v) {
                      searchCountry.value = v;
                    },
                    decoration: InputDecoration(
                      hintText: "Search country...",
                      fillColor: Colors.white10,
                      isDense: true,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 25),
                      hintStyle: customTextStyleBody(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: kWhiteColor),
                      prefixIcon: const Icon(Remix.search_2_fill, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        return Obx(
                          () => countries[index]["name"].contains(RegExp(
                                      searchCountry.value,
                                      caseSensitive: false)) ||
                                  countries[index]["code"].contains(RegExp(
                                      searchCountry.value,
                                      caseSensitive: false))
                              ? ListTile(
                                  onTap: () {
                                    countryController.text =
                                        countries[index]["name"];
                                    codeController.text =
                                        countries[index]["code"];
                                    searchCountryController.clear();
                                    Get.back();
                                  },
                                  minLeadingWidth: 0,
                                  leading: Text(countries[index]["code"],
                                      style: customTextStyleBody()),
                                  title: Text(countries[index]["name"],
                                      style: customTextStyleBody()),
                                )
                              : const SizedBox.shrink(),
                        );
                      }),
                ),
              ],
            );
          }),
      isScrollControlled: true,
      barrierColor: Colors.white10,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: kBlackColor);

  void openZipcodeSheet() {
    Get.bottomSheet(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, kToolbarHeight, 15, 0),
              child: Row(
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
                  Text("Select Zipcode",
                      style: fontHeading(
                          fontSize: 20.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
              child: TextFormField(
                controller: searchZipcodeController,
                style: customTextStyleBody(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kWhiteColor),
                keyboardType: TextInputType.text,
                onChanged: (v) {
                  searchZipcode.value = v;
                },
                decoration: InputDecoration(
                  hintText: "Search zipcode...",
                  fillColor: Colors.white10,
                  filled: true,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                  hintStyle: customTextStyleBody(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: kWhiteColor),
                  prefixIcon: const Icon(Remix.search_2_fill, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Obx(
                    () => GestureDetector(
                      onTap: () {
                        selectedTargetCountry.value =
                            targetCountries[index]["country"];
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: ShapeDecoration(
                          color: selectedTargetCountry.value ==
                                  targetCountries[index]["country"]
                              ? null
                              : Colors.white10,
                          shape: const StadiumBorder(),
                          gradient: selectedTargetCountry.value ==
                                  targetCountries[index]["country"]
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xffdb3445),
                                    Color(0xfff71735)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                        ),
                        child: Text(targetCountries[index]["country"],
                            style: fontPoppins()),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, i) => const SizedBox(width: 10),
                itemCount: targetCountries.length,
              ),
            ),
            Expanded(
              child: Obx(
                () => FirestoreListView(
                    query: targetZipcodesCollection
                        .where("country",
                            isEqualTo: selectedTargetCountry.value)
                        .orderBy("state"),
                    padding: const EdgeInsets.all(15),
                    itemBuilder: (context, zicode) {
                      return ListTile(
                        onTap: () {
                          zipcodeController.text = zicode["zipcode"];
                          Get.back();
                        },
                        minLeadingWidth: 0,
                        title: Text(zicode["city"], style: fontPoppins()),
                        subtitle: Text(zicode["zipcode"], style: fontPoppins()),
                        trailing: Text(zicode["state"], style: fontPoppins()),
                      );
                    }),
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        barrierColor: Colors.white10,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        backgroundColor: kBlackColor);
  }

  @override
  void onInit() {
    fetchTargetCountries();
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    signButtonFocus.dispose();
    emailFocus.dispose();
    zipcodeController.dispose();
    searchZipcodeController.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
