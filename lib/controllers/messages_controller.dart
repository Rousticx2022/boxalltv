import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/models.dart';
import 'bottomtab_controller.dart';

class MessagesController extends GetxController {
  String? uid = Get.parameters["uid"],
      fid = Get.parameters["fid"],
      chatID = Get.parameters["chatID"];
  RxBool isTyping = false.obs;
  final TextEditingController messageController = TextEditingController();

  List pickedFiles = [];
  RxString showTimeID = "".obs;

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    await chatsCollection.doc(chatID).collection("messages").add({
      "message": messageController.text.trim(),
      "type": "text",
      "sentBy": uid!,
      "sentOn": DateTime.now(),
    });
    messageController.clear();
    http.Response response = await http.post(
      Uri.parse("http://65.109.39.177:7110/send_notification"),
      body: jsonEncode({
        "title": Get.find<BottomTabController>().userData["name"],
        "message": messageController.text.trim(),
        "uid": fid,
      }),
    );
  }

  Column senderView(MessageModel chat) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: 50, maxWidth: Get.width / 1.5),
              child: GestureDetector(
                onTap: () {
                  if (showTimeID.value == chat.chatID) {
                    showTimeID.value = "";
                    return;
                  }
                  showTimeID.value = chat.chatID;
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: kWhiteColor.withValues(alpha: 0.06),
                    border: Border.all(color: kWhiteColor),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20)),
                  ),
                  child: chat.type == "text"
                      ? Text(
                          chat.message,
                          style: fontBody(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        )
                      : fileView(chat.message),
                ),
              ),
            ),
          ),
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInCirc,
              switchOutCurve: Curves.easeOutExpo,
              child: showTimeID.value == chat.chatID
                  ? Text(
                      DateFormat("hh:mm a").format(chat.sentOn.toDate()),
                      style: fontBody(
                          color: const Color(0xff9FB5C6),
                          fontSize: 10,
                          fontWeight: FontWeight.w400),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      );

  Column receiverView(MessageModel chat) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: 0, maxWidth: Get.width / 1.5),
              child: GestureDetector(
                onTap: () {
                  if (showTimeID.value == chat.chatID) {
                    showTimeID.value = "";
                    return;
                  }
                  showTimeID.value = chat.chatID;
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: kWhiteColor.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                  ),
                  child: chat.type == "text"
                      ? Text(
                          chat.message,
                          style: fontBody(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        )
                      : fileView(chat.message),
                ),
              ),
            ),
          ),
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInCirc,
              switchOutCurve: Curves.easeOutExpo,
              child: showTimeID.value == chat.chatID
                  ? Text(
                      DateFormat("hh:mm a").format(chat.sentOn.toDate()),
                      style: fontBody(
                          color: const Color(0xff9FB5C6),
                          fontSize: 10,
                          fontWeight: FontWeight.w400),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      );

  Future<void> pickFiles() async {
    List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['jpg', 'png', 'mp4', 'jpeg', 'gif'],
    );

    pickedFiles = result
        .map((file) => {"path": file.path!, "extension": file.name.split(".").last})
        .toList();

    var request = http.MultipartRequest('POST',
        Uri.parse('http://appdev.gameinghub.com/gameinghub/postContent'));
    request.fields.addAll({'type': 'chat', 'uid': uid!});

    for (var element in pickedFiles) {
      request.files
          .add(await http.MultipartFile.fromPath('file', element["path"]));
    }
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map res = jsonDecode(await response.stream.bytesToString());
      for (var i in res["details"]) {
        await chatsCollection.doc(chatID).collection("messages").add({
          "message": i["url"],
          "type": "file",
          "sentBy": uid!,
          "sentOn": DateTime.now(),
        });
      }
      await http.post(
        Uri.parse("http://65.109.39.177:7110/send_notification"),
        body: jsonEncode({
          "title": Get.find<BottomTabController>().userData["name"],
          "message": "${res["details"].length} files",
          "uid": fid,
        }),
      );
    } else {
      customSnackBar(text: response.reasonPhrase.toString());
    }
  }

  Widget fileView(String message) {
    Widget? view;
    String fileType = message.split(".").last;

    switch (fileType) {
      case "jpg":
      case "jpeg":
      case "png":
      case "gif":
        view = GestureDetector(
          onTap: () {
            // Get.to(() => ViewImage(imageURL: message), fullscreenDialog: true);
          },
          child: CachedNetworkImage(
              imageUrl: message,
              fit: BoxFit.cover,
              width: Get.width / 2,
              height: Get.width / 2),
        );
        break;
      case "mp4":
        view = GestureDetector(
          onTap: () {
            //Get.to(() => ViewVideo(videoURL: message), fullscreenDialog: true);
          },
          child: Container(
            color: kWhiteColor.withValues(alpha: 0.1),
            width: Get.width / 2,
            height: Get.width / 2,
            child: const Center(child: Icon(Icons.play_circle, size: 70)),
          ),
        );
        break;
    }

    return view!;
  }

  @override
  void onReady() async {
    await usersCollection.doc(uid!).collection("messages").doc(fid!).update({
      "unreadCount": 0,
    });
    super.onReady();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
