import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/form_validators.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/bottomtab_controller.dart';
import '../../utils/collections.dart';
import '../../utils/form_builder.dart';

class BecomeAnAdvertiser extends StatefulWidget {
  final String uid;
  const BecomeAnAdvertiser({super.key, required this.uid});

  @override
  State<BecomeAnAdvertiser> createState() => _BecomeAnAdvertiserState();
}

class _BecomeAnAdvertiserState extends State<BecomeAnAdvertiser> {
  bool loading = false;

  final formKey = GlobalKey<FormState>();

  final TextEditingController businessNameController = TextEditingController(),
      businessIDController = TextEditingController(),
      signedAdAgreementController = TextEditingController(),
      businessAddressController = TextEditingController();

  String signedAdAgreementPath = "";

  Future<void> pickFile() async {
    List<PlatformFile> result = await FilePicker.pickFiles();

    if (result.isNotEmpty) {
      signedAdAgreementController.text = result.single.name;
      setState(() {
        signedAdAgreementPath = result.single.path!;
      });
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    final storageRef = FirebaseStorage.instance.ref();

    String ext = signedAdAgreementPath.split(".").last;
    int fileName = DateTime.now().millisecondsSinceEpoch;
    String imageURL = "";
    try {
      final postRef = storageRef.child(
        "advertisers/${widget.uid}/agreement_$fileName.$ext",
      );
      await postRef.putFile(File(signedAdAgreementPath));
      imageURL = await postRef.getDownloadURL();
    } on FirebaseException catch (e) {
      customSnackBar(text: e.code);
    }

    await advertisersCollection.doc(widget.uid).set({
      "active": false,
      "activated": false,
      "email": Get.find<BottomTabController>().userData["email"],
      "businessName": businessNameController.text,
      "businessID": businessIDController.text,
      "businessAddress": businessAddressController.text,
      "signedAdAgreement": imageURL,
      "totalAds": 0,
      "totalViews": 0,
      "uid": widget.uid,
      "createdAt": DateTime.now(),
    });

    setState(() {
      loading = false;
    });

    Get.back();

    Get.defaultDialog(
      title: "Submitted",
      titleStyle: fontHeading(
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        color: kWhiteColor,
      ),
      content: Text(
        "Your request to become a advertiser has been submitted successfully. Documents verification can take up to 3-4 business days",
        style: fontBody(),
        textAlign: TextAlign.center,
      ),
      barrierDismissible: false,
      backgroundColor: kGreyColor2,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            backgroundColor: kButtonColor,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          ),
          child: Text(
            "Close",
            style: customTextStyleBody(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    businessNameController.dispose();
    businessIDController.dispose();
    businessAddressController.dispose();
    signedAdAgreementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff000000), Color(0xff203A43), Color(0xff000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Become an\nAdvertiser',
                      style: fontPoppins(
                        color: kWhiteColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Image.asset("assets/ads.png", width: context.width / 3),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                child: Text(
                  "You need to provide valid documents and information about your business. Our team will verify your documents within 3 business days.",
                  style: fontPoppins(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              Text(
                "Fill in the form below to\nbecome an advertiser",
                style: fontPoppins(
                  color: kWhiteColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 18.sp,
                ),
              ),
              Divider(
                color: kWhiteColor.withValues(alpha: 0.5),
                thickness: 6,
                endIndent: context.width / 2,
              ),
              const SizedBox(height: 20),
              Formbuilder(
                controller: businessNameController,
                validator: fieldValidator,
                inputType: TextInputType.text,
                noPadding: true,
                label: "Business Name",
              ).buildTextField(),
              const SizedBox(height: 20),
              Formbuilder(
                controller: businessAddressController,
                validator: fieldValidator,
                inputType: TextInputType.multiline,
                noPadding: true,
                maxLines: 3,
                label: "Business Address",
              ).buildTextField(),
              const SizedBox(height: 20),
              Formbuilder(
                controller: businessIDController,
                validator: fieldValidator,
                inputType: TextInputType.text,
                noPadding: true,
                label: "Business ID",
              ).buildTextField(),
              const SizedBox(height: 20),
              TextFormField(
                controller: signedAdAgreementController,
                keyboardType: TextInputType.text,
                readOnly: true,
                style: customTextStyleBody(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
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
                  labelText: "Signed Ad Agreement",
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
      ),
    );
  }
}
