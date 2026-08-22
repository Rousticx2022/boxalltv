import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../services/ads_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';
import '../widgets/comment_box.dart';

class UploadController extends GetxController {
  RxBool isUploadingPost = false.obs;
  TextEditingController commentController = TextEditingController();

  Future<void> createPost({
    required String uid,
    required String vid,
    required String caption,
    required List content,
    required int recordingStartedFrom,
    required String isTrimmed,
  }) async {
    isUploadingPost.value = true;
    List contentUrls = [];

    if (content.isNotEmpty) {
      FTPConnect ftpConnect = FTPConnect(
        "storage.bunnycdn.com",
        user: const String.fromEnvironment('FTP_USER'),
        pass: const String.fromEnvironment('FTP_PASS'),
      );
      await ftpConnect.connect();
      await ftpConnect.changeDirectory("posts");
      await ftpConnect.createFolderIfNotExist(uid);
      await ftpConnect.changeDirectory(uid).then((value) async {
        for (var element in content) {
          String ext = element["path"].split(".").last;
          int fileName = DateTime.now().millisecondsSinceEpoch;

          bool videoStatus = await ftpConnect.uploadFileWithRetry(
            File(element["path"]),
            pRetryCount: 3,
            pRemoteName: "post_$fileName.$ext",
          );
          if (videoStatus) {
            if (["jpg", "jpeg", "png", "gif", "webp"].contains(ext)) {
              contentUrls.add({
                "url":
                    "https://frametv.b-cdn.net/posts/$uid/post_$fileName.$ext",
                "type": "image",
              });
            } else {
              contentUrls.add({
                "url":
                    "https://frametv.b-cdn.net/posts/$uid/post_$fileName.$ext",
                "type": "video",
              });
            }
          }
        }
        ftpConnect.disconnect();
      });
    }

    await postsCollection
        .add({
          "uid": uid,
          "caption": caption.trim(),
          "content": contentUrls,
          "active": true,
          "comments": 0,
          "engagement": 0,
          "likes": 0,
          "shares": 0,
          'vid': vid,
          "isTrimmed": isTrimmed == "trimmed",
          "recordingStartedFrom": recordingStartedFrom,
          "postDate": DateTime.now(),
        })
        .then((value) async {
          await postDataCollection.doc(value.id).set({
            "likes": [],
            "shares": [],
          });
          isUploadingPost.value = false;
          customSnackBar(text: "Posted successfully");
          Get.find<AdsService>().showRewardedAd(1);
        });
  }

  void openPostCommentsSheet({
    required String uid,
    required String postOwner,
    required String postID,
  }) {
    Get.bottomSheet(
      KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return StatefulBuilder(
            builder: (context, setState) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  height: isKeyboardVisible ? Get.height / 3 : Get.height / 1.4,
                  child: Column(
                    children: [
                      Row(
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
                            "Comments",
                            style: fontHeading(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: FirestoreListView.separated(
                          reverse: true,
                          emptyBuilder: (context) {
                            return Center(
                              child: Text(
                                "No comments yet!",
                                style: fontBody(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: kWhiteColor,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context) {
                            return customCircularProgress(
                              strokeColor: kSocialPrimaryColor,
                            );
                          },
                          query: postDataCollection
                              .doc(postID)
                              .collection("comments")
                              .orderBy("postedOn", descending: true),
                          padding: const EdgeInsets.all(15),
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, comment) =>
                              commentBox(comment),
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(color: kGreyColor1);
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: commentController,
                              style: customTextStyleBody(color: kWhiteColor),
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                fillColor: Colors.grey.withValues(alpha: 0.2),
                                filled: true,
                                hintText: "Write your comment",
                                suffixIcon: IconButton(
                                  icon: const Icon(Remix.send_plane_fill),
                                  color: kSocialPrimaryColor,
                                  onPressed: () async {
                                    if (commentController.text.trim().isEmpty) {
                                      return;
                                    }
                                    await postDataCollection
                                        .doc(postID)
                                        .collection("comments")
                                        .add({
                                          "comment": commentController.text
                                              .trim(),
                                          "commentator": uid,
                                          "postedOn": DateTime.now(),
                                        })
                                        .then((value) async {
                                          commentController.clear();
                                          await postsCollection
                                              .doc(postID)
                                              .update({
                                                "comments":
                                                    FieldValue.increment(1),
                                              });
                                        });
                                  },
                                ),
                                hintStyle: customTextStyleBody(
                                  color: kWhiteColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: kBlackColor.withValues(alpha: 0.5),
      barrierColor: Colors.white12,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
    );
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
