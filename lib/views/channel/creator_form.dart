import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../utils/form_builder.dart';
import '../../utils/form_validators.dart';
import '../../utils/styles.dart';

class CreatorForm extends StatefulWidget {
  final String uid;
  const CreatorForm({super.key, required this.uid});

  @override
  State<CreatorForm> createState() => _CreatorFormState();
}

class _CreatorFormState extends State<CreatorForm> {
  final formKey = GlobalKey<FormState>();

  BottomTabController bottomTabController = Get.find();
  bool loading = false;

  final TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      channelController = TextEditingController();

  List files = [];

  Future<void> uploadForm() async {
    if (!formKey.currentState!.validate()) return;

    if (files.isEmpty) {
      customSnackBar(text: "Please submit documents");
      return;
    }
    setState(() {
      loading = true;
    });
    List documents = [];
    final storageRef = FirebaseStorage.instance.ref();
    for (Map file in files) {
      try {
        final postRef =
            storageRef.child("creators/${widget.uid}/doc_${file["name"]}");
        await postRef.putFile(File(file["path"]));
        documents.add(await postRef.getDownloadURL());
      } on FirebaseException catch (e) {
        customSnackBar(text: e.code);
      }
    }

    await creatorsCollection.doc(widget.uid).set({
      "name": nameController.text,
      "email": emailController.text.toLowerCase(),
      "channelName": channelController.text,
      "status": "pending",
      "active": false,
      "activated": false,
      "createdAt": DateTime.now(),
      "documents": documents,
      "overallPopularity": 0,
      "totalMovies": 0,
      "totalSeries": 0,
      "totalRevenue": 0,
    });

    Get.back();

    Get.defaultDialog(
        title: "Submitted",
        titleStyle: fontHeading(
            fontWeight: FontWeight.w600, fontSize: 20.sp, color: kWhiteColor),
        content: Text(
          "Your request to become a creator has been submitted successfully. Documents verification can take up to 3-4 business days",
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
            child: Text("Close",
                style: customTextStyleBody(
                    fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        ]);
  }

  Future<void> pickFiles() async {
    List<PlatformFile> result = await FilePicker.pickFiles(

        type: FileType.custom,
        allowedExtensions: ["pdf", "doc", "docx", "jpeg", " jpg", "png"]);
    if (result.isEmpty) {
      return;
    }

    setState(() {
      files.addAll(result
          .map((file) => {
                "path": file.path!,
                "name": file.name,
                "size": 0,
                "ext": file.name.split(".").last
              })
          .toList());
    });
  }

  @override
  void initState() {
    nameController.text = bottomTabController.userData["name"];
    emailController.text = bottomTabController.userData["email"];
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creator Form', style: customTextStyleHeadline()),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Formbuilder(
                    controller: nameController,
                    validator: nameValidator,
                    inputType: TextInputType.name,
                    pIcon: "assets/user_icon.png",
                    label: "Enter Full Name")
                .buildTextField(),
            Formbuilder(
                    controller: emailController,
                    validator: emailValidator,
                    inputType: TextInputType.emailAddress,
                    pIcon: "assets/email_icon.png",
                    label: "Enter Email")
                .buildTextField(),
            Formbuilder(
                    controller: channelController,
                    validator: fieldValidator,
                    inputType: TextInputType.text,
                    pIcon: "assets/channel_icon.png",
                    label: "Enter Channel Name")
                .buildTextField(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 5, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Submit documents",
                      style: customTextStyleBody(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.sp)),
                  IconButton(
                      onPressed: () => pickFiles(),
                      icon: const Icon(Icons.add_circle)),
                ],
              ),
            ),
            ...List.generate(
              files.length,
              (index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      files.removeAt(index);
                    });
                  },
                  tileColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  title: Text("${files[index]["name"]}",
                      style: fontBody(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      "${(files[index]["size"] / 1000).toStringAsFixed(2)}kb",
                      style: fontBody(fontWeight: FontWeight.w400)),
                  trailing: const Icon(Icons.remove_circle),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: kBlackColor,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: loading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customCircularProgress(strokeColor: kPrimaryColor),
                  ],
                )
              : TextButton(
                  onPressed: () => uploadForm(),
                  style: TextButton.styleFrom(
                      backgroundColor: kButtonColor,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: Text("Submit",
                      style: customTextStyleBody(
                          fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ),
        ),
      ),
    );
  }
}
