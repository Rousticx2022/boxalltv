import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/bottomtab_controller.dart';
import '../../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/form_validators.dart';

part 'publish_ad_ext2.dart';

class PublishAd extends StatefulWidget {
  const PublishAd({super.key});

  @override
  State<PublishAd> createState() => _PublishAdState();
}

class _PublishAdState extends State<PublishAd> {
  String uid = Get.find<BottomTabController>().uid!;
  final formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController(),
      logoController = TextEditingController(),
      brandWebsiteController = TextEditingController(),
      zipcodesController = TextEditingController(),
      searchZipcodeController = TextEditingController(),
      videoUrlController = TextEditingController(),
      totalBudgetController = TextEditingController();

  RxString searchZipcode = "".obs;
  RxList selectedZipcodes = [].obs;

  bool loading = false;
  List targetCountries = [];
  Rx selectedTargetCountry = "".obs;
  String logoPath = "", videoPath = "";

  Future<void> pickFile() async {
    List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.image,
    );

    if (result.isNotEmpty) {
      logoController.text = result.single.name;
      setState(() {
        logoPath = result.single.path!;
      });
    }
  }

  Future<void> pickVideo() async {
    List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.video,
    );

    if (result.isNotEmpty) {
      videoUrlController.text = result.single.name;
      setState(() {
        videoPath = result.single.path!;
      });
    }
  }

  Future<void> fetchTargetCountries() async {
    QuerySnapshot countries = await targetCountriesCollection
        .orderBy("country")
        .get();
    targetCountries = countries.docs;
    selectedTargetCountry.value = targetCountries.first["country"];
    setState(() {});
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    final storageRef = FirebaseStorage.instance.ref();

    String ext = logoPath.split(".").last;
    int fileName = DateTime.now().millisecondsSinceEpoch;
    String imageURL = "", videoURL = "";
    try {
      final postRef = storageRef.child(
        "custom_ads/$uid/brandlogo_$fileName.$ext",
      );
      await postRef.putFile(File(logoPath));
      imageURL = await postRef.getDownloadURL();
    } on FirebaseException catch (e) {
      customSnackBar(text: e.code);
    }

    try {
      final videoRef = storageRef.child("custom_ads/$uid/ad_$fileName.$ext");
      await videoRef.putFile(File(logoPath));
      videoURL = await videoRef.getDownloadURL();
    } on FirebaseException catch (e) {
      customSnackBar(text: e.code);
    }

    await customVideoAdsCollection.doc(uid).set({
      "active": false,
      "budgetPerAds": 0,
      "createdAt": DateTime.now(),
      "frequency": 50,
      "logo": imageURL,
      "status": "pending",
      "title": titleController.text,
      "totalAdsShown": 0,
      "totalBudget": totalBudgetController.text,
      "uid": uid,
      "url": videoURL,
      "zipcodes": selectedZipcodes,
    });

    setState(() {
      loading = false;
    });

    customSnackBar(text: "Ad submitted successfully");

    Get.back();
  }

  @override
  void initState() {
    fetchTargetCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Publish Ad"),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            TextFormField(
              controller: titleController,
              keyboardType: TextInputType.text,
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Brand Name/ Title",
                labelStyle: customTextStyleBody(
                  color: kWhiteColor,
                  fontSize: 16.sp,
                ),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: logoController,
              keyboardType: TextInputType.text,
              readOnly: true,
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                labelText: "Brand Logo",
                labelStyle: customTextStyleBody(
                  color: kWhiteColor,
                  fontSize: 16.sp,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.upload_file),
                  color: kWhiteColor.withValues(alpha: 0.7),
                  onPressed: () => pickFile(),
                ),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            Text(
              "Upload the video file of the advertisement. Please upload the video in mp4 or mov format in Full HD resolution",
              style: fontPoppins(
                color: kWhiteColor.withValues(alpha: 0.7),
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: videoUrlController,
              keyboardType: TextInputType.text,
              readOnly: true,
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                labelText: "Ad Video",
                labelStyle: customTextStyleBody(
                  color: kWhiteColor,
                  fontSize: 16.sp,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.upload_file),
                  color: kWhiteColor.withValues(alpha: 0.7),
                  onPressed: () => pickVideo(),
                ),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: brandWebsiteController,
              keyboardType: TextInputType.url,
              style: fontPoppins(color: kWhiteColor, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Website/ Brand URL (Optional)",
                labelStyle: fontPoppins(color: kWhiteColor, fontSize: 16.sp),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: totalBudgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: fontPoppins(color: kWhiteColor, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Total Budget",
                labelStyle: fontPoppins(color: kWhiteColor, fontSize: 16.sp),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            Text(
              "Select the zipcodes you want to target your ad",
              style: fontPoppins(
                color: kWhiteColor.withValues(alpha: 0.7),
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              readOnly: true,
              controller: zipcodesController,
              keyboardType: TextInputType.number,
              onTap: () => openZipcodeSheet(),
              minLines: 1,
              maxLines: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: fontPoppins(color: kWhiteColor, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Zipcodes",
                labelStyle: fontPoppins(color: kWhiteColor, fontSize: 16.sp),
                suffixIcon: const Icon(Icons.add, color: kWhiteColor),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            Text(
              "Once you submit the ad will be verified by our team to prevent plagiarizing and maintain a good community. After verification your ad will go live once payment is successful. You can check approved ads under pending section",
              style: fontPoppins(
                color: kWhiteColor.withValues(alpha: 0.7),
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            loading
                ? Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20,
                    ),
                    child: customCircularProgress(
                      strokeColor: kButtonColor,
                      strokeWidth: 5,
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      save();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15,
                      ),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        gradient: LinearGradient(
                          colors: [Color(0xffdb3445), Color(0xfff71735)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Submit",
                        style: fontBody(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: kWhiteColor,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
