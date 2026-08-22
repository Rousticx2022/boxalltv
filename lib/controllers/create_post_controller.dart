import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';
import 'upload_controller.dart';

class CreatePostController extends GetxController {
  String? uid = Get.parameters["uid"],
      path = Get.parameters["path"],
      type = Get.parameters["type"];
  int? recordingStartedFrom = int.parse(
    Get.parameters["recordingStartedFrom"] ?? "0",
  );
  String isTrimmed = Get.parameters["isTrimmed"] ?? "normal",
      vid = Get.parameters["vid"] ?? "";

  final TextEditingController captionController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  RxList content = [].obs;
  List<Map> icons = [];

  RxMap extra = {}.obs;

  void pickImage() async {
    if (content.length == 10) {
      customSnackBar(text: "Max upload limit 10");
      return;
    }
    final List<XFile> images = await imagePicker.pickMultiImage();
    if (images.isEmpty) return;

    for (var element in images) {
      content.add({"path": element.path, "type": "image"});
    }
    // content.value = content.sublist(0, 10);
    Get.back();
  }

  void pickVideo() async {
    if (content.length == 10) {
      customSnackBar(text: "Max upload limit 10");
      return;
    }
    final XFile? video = await imagePicker.pickVideo(
      source: ImageSource.gallery,
    );
    if (video == null) return;
    content.add({"path": video.path, "type": "video"});
    // content.value = content.sublist(0, 10);
    Get.back();
  }

  @override
  void onInit() {
    icons = [
      {
        "icon": Icons.photo_sharp,
        "text": "Add Image",
        "callback": () => pickImage(),
      },
      {
        "icon": Icons.video_camera_back,
        "text": "Add Video",
        "callback": () => pickVideo(),
      },
    ];

    if (path != null) {
      content.add({"path": path, "type": type});
    }

    super.onInit();
  }

  Future<void> uploadPost() async {
    if (captionController.text.isEmpty && content.isEmpty) {
      customSnackBar(text: "Cannot post blank");
      return;
    }

    Get.find<UploadController>().createPost(
      uid: uid!,
      vid: vid,
      recordingStartedFrom: recordingStartedFrom!,
      isTrimmed: isTrimmed,
      caption: captionController.text,
      content: content,
    );
    Get.back();
    Get.defaultDialog(
      title: "Uploading post",
      titleStyle: fontHeading(
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        color: kWhiteColor,
      ),
      content: Text(
        "Your post will be uploaded in few minutes. Please Do not close the application now.",
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

  void openOptionSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        decoration: const BoxDecoration(
          color: kBlackColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: <Widget>[
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 30,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: icons.length,
                itemBuilder: (context, index) => ListTile(
                  onTap: icons[index]["callback"],
                  leading: Icon(icons[index]["icon"], color: kPrimaryColor),
                  minLeadingWidth: 0,
                  title: Text(icons[index]["text"]),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierColor: kWhiteColor.withValues(alpha: 0.1),
    );
  }

  @override
  void onClose() {
    captionController.dispose();
    super.onClose();
  }
}
