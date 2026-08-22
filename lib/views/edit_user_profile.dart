import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/form_builder.dart';
import '../utils/form_validators.dart';
import '../utils/styles.dart';
import '../utils/collections.dart';

part 'edit_user_profile_ext2.dart';

part 'edit_user_profile_ext.dart';

class EditUserProfile extends StatefulWidget {
  final String uid;
  const EditUserProfile({super.key, required this.uid});

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final formKey = GlobalKey<FormState>();
  final ImagePicker imagePicker = ImagePicker();
  var imageName = "", imageSize = 0, imagePath = "";
  RxString searchCountry = "".obs, searchZipcode = "".obs;
  bool passwordVisible = false;

  bool loading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(),
      searchCountryController = TextEditingController(),
      searchZipcodeController = TextEditingController(),
      codeController = TextEditingController(),
      zipcodeController = TextEditingController(),
      passwordController = TextEditingController(),
      newEmailController = TextEditingController(),
      countryController = TextEditingController();

  List targetCountries = [];
  Rx selectedTargetCountry = "".obs;

  void togglePassword() {
    passwordVisible = !passwordVisible;
  }

  Future<void> fetchUser() async {
    DocumentSnapshot user = await usersCollection.doc(widget.uid).get();
    nameController.text = user["name"];
    emailController.text = user["email"];
    phoneController.text = user["phoneNumber"];
    countryController.text = user["country"];
    zipcodeController.text = user["zipcode"];
  }

  Future<void> fetchTargetCountries() async {
    QuerySnapshot countries = await targetCountriesCollection
        .orderBy("country")
        .get();
    targetCountries = countries.docs;
    selectedTargetCountry.value = targetCountries.first["country"];
    setState(() {});
  }

  void pickImage({bool gallery = false}) async {
    final XFile? image = await imagePicker.pickImage(
      source: gallery ? ImageSource.gallery : ImageSource.camera,
    );
    if (image == null) return;
    imageSize = await image.length() ~/ 1000;
    if (imageSize > 5400) {
      customSnackBar(text: "Max file limit exceeds");
      return;
    }

    setState(() {
      imageName = image.name;
      imagePath = image.path;
    });
  }

  void openImageSelect() => Get.defaultDialog(
    title: "Select Profile Picture",
    titleStyle: customTextStyleHeadline(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: kWhiteColor,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () {
            pickImage(gallery: true);
            Get.back();
          },
          title: const Text(
            "Open Gallery",
            style: TextStyle(fontSize: 15, color: kButtonColor),
          ),
        ),
        ListTile(
          onTap: () {
            pickImage();
            Get.back();
          },
          title: const Text(
            "Open Camera",
            style: TextStyle(fontSize: 15, color: kButtonColor),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.grey.shade900,
  );

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
                        color: Colors.white12,
                        shape: CircleBorder(),
                      ),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  Text(
                    "Select Countries",
                    style: fontHeading(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
              child: TextFormField(
                controller: searchCountryController,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: kWhiteColor,
                ),
                keyboardType: TextInputType.text,
                onChanged: (v) {
                  searchCountry.value = v;
                },
                decoration: InputDecoration(
                  hintText: "Search country...",
                  fillColor: Colors.white10,
                  filled: true,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 25,
                  ),
                  hintStyle: customTextStyleBody(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kWhiteColor,
                  ),
                  prefixIcon: const Icon(Remix.search_2_fill, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => searchCountry.value.isEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              countryController.text = countries[index]["name"];
                              codeController.text = countries[index]["code"];
                              searchCountryController.clear();
                              Get.back();
                            },
                            minLeadingWidth: 0,
                            leading: Text(
                              countries[index]["code"],
                              style: customTextStyleBody(),
                            ),
                            title: Text(
                              countries[index]["name"],
                              style: customTextStyleBody(),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          return countries[index]["name"].contains(
                                    RegExp(
                                      searchCountry.value,
                                      caseSensitive: false,
                                    ),
                                  ) ||
                                  countries[index]["code"].contains(
                                    RegExp(
                                      searchCountry.value,
                                      caseSensitive: false,
                                    ),
                                  )
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
                                  leading: Text(
                                    countries[index]["code"],
                                    style: customTextStyleBody(),
                                  ),
                                  title: Text(
                                    countries[index]["name"],
                                    style: customTextStyleBody(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
              ),
            ),
          ],
        );
      },
    ),
    isScrollControlled: true,
    barrierColor: Colors.white10,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    backgroundColor: Colors.black,
  );

  @override
  void initState() {
    fetchUser();
    fetchTargetCountries();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    searchCountryController.dispose();
    codeController.dispose();
    countryController.dispose();
    zipcodeController.dispose();
    searchZipcodeController.dispose();
    newEmailController.dispose();
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Edit Profile"),
        ),
        body: StreamBuilder(
          stream: usersCollection.doc(widget.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return Center(
                child: customCircularProgress(
                  strokeColor: Theme.of(context).primaryColor,
                ),
              );
            }
            DocumentSnapshot userDocs = userSnapshot.data!;
            return Form(
              key: formKey,
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: imagePath.isEmpty
                              ? CachedNetworkImage(
                                  imageUrl: userDocs["profileImage"],
                                  fit: BoxFit.cover,
                                  width: 32.w,
                                  height: 32.w,
                                )
                              : Image.file(
                                  File(imagePath),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: openImageSelect,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffdb3445),
                              ),
                              child: const Icon(
                                Remix.camera_2_fill,
                                color: kWhiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Formbuilder(
                    controller: nameController,
                    validator: nameValidator,
                    inputType: TextInputType.name,
                    pIcon: "assets/user_icon.png",
                    label: "Change Username",
                  ).buildTextField(),
                  Formbuilder(
                    controller: phoneController,
                    validator: phoneValidator,
                    inputType: TextInputType.number,
                    pIcon: "assets/phone_icon.png",
                    label: "Enter Phone number",
                  ).buildTextField(),
                  Formbuilder(
                    controller: countryController,
                    readOnly: true,
                    validator: countryValidator,
                    inputType: TextInputType.text,
                    pIcon: "assets/location_icon.png",
                    onTap: selectCountry,
                    label: "Select Country",
                  ).buildSelectField(),
                  Formbuilder(
                    controller: zipcodeController,
                    readOnly: true,
                    onTap: () => openZipcodeSheet(),
                    validator: fieldValidator,
                    inputType: TextInputType.text,
                    pIcon: "assets/zipcode_icon.png",
                    label: "Enter Zipcode",
                  ).buildTextField(),
                  loading
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 15,
                          ),
                          child: customCircularProgress(
                            strokeColor: kButtonColor,
                            strokeWidth: 5,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              loading = true;
                            });
                            save();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 15,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 15,
                            ),
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              gradient: LinearGradient(
                                colors: [Color(0xffdb3445), Color(0xfff71735)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Update",
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
            );
          },
        ),
      ),
    );
  }
}
