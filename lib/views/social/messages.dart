import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/models.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:remixicon/remixicon.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as time_ago;

import '../../controllers/messages_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/collections.dart';

class Messages extends GetView<MessagesController> {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(left: 20),
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.white10,
            ),
            child: const Icon(
              Remix.arrow_left_line,
              color: kSocialPrimaryColor,
            ),
          ),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: usersCollection.doc(controller.fid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            DocumentSnapshot udoc = snapshot.data!;
            return ListTile(
              onTap: () => {},
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              leading: Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: kBlackColor,
                  border: Border.all(color: kGreyColor2, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: udoc["profileImage"],
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                udoc["name"],
                style: fontBody(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                udoc["active"]
                    ? "Online"
                    : "Active ${time_ago.format(udoc["lastSeen"].toDate())}",
                style: fontBody(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff9FB5C6),
                ),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FirestoreListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              reverse: true,
              query: chatsCollection
                  .doc(controller.chatID!)
                  .collection("messages")
                  .orderBy("sentOn", descending: true),
              itemBuilder: (context, documentSnapshot) {
                MessageModel chat = MessageModel.fromDocument(documentSnapshot);
                return chat.sentBy == controller.uid!
                    ? controller.senderView(chat)
                    : controller.receiverView(chat);
              },
            ),
          ),
          Container(
            height: kBottomNavigationBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            width: context.width,
            decoration: const BoxDecoration(color: kSocialPrimaryColor),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.messageController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        controller.isTyping.value = false;
                      } else {
                        controller.isTyping.value = true;
                      }
                    },
                    style: fontBody(
                      fontSize: 15,
                      color: kBlackColor,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: "Say something nice...",
                      hintStyle: fontBody(
                        fontSize: 15,
                        color: kBlackColor,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Obx(
                  () => controller.isTyping.value
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () => controller.pickFiles(),
                          color: kBlackColor,
                          icon: const Icon(Remix.attachment_2),
                        ),
                ),
                InkWell(
                  onTap: () => controller.sendMessage(),
                  child: Image.asset("assets/send_chat_icon.png", width: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
