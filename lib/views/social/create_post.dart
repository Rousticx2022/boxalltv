import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

import '../../controllers/create_post_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';

class CreatePost extends GetView<CreatePostController> {
  const CreatePost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post",
            style: fontHeading(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                color: kWhiteColor)),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(left: 20),
            decoration: const ShapeDecoration(
                shape: CircleBorder(), color: Colors.white10),
            child:
                const Icon(Remix.arrow_left_line, color: kSocialPrimaryColor),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () => controller.uploadPost(),
                style: TextButton.styleFrom(
                  backgroundColor: kSocialPrimaryColor,
                  foregroundColor: kWhiteColor,
                  shape: const StadiumBorder(),
                ),
                child: Text("Post",
                    style: customTextStyleBody(
                        color: kBlackColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: kGreyColor2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: controller.captionController,
                style: customTextStyleBody(fontSize: 18),
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "What's on your mind",
                  hintStyle: customTextStyleBody(fontSize: 18),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.content.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1,
                maxCrossAxisExtent: 150,
              ),
              itemBuilder: (context, index) {
                return controller.content[index]["type"] == "image"
                    ? Container(
                        height: context.width - 20,
                        margin: const EdgeInsets.only(bottom: 15),
                        width: context.width - 20,
                        child: Stack(
                          children: [
                            Image.file(File(controller.content[index]["path"]),
                                fit: BoxFit.cover,
                                height: context.width - 20,
                                width: context.width - 20),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Wrap(
                                spacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final Uint8List editedImage =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ImageEditor(
                                                image: File(controller
                                                        .content[index]["path"])
                                                    .readAsBytesSync())),
                                      );
                                      final tempDir =
                                          await getTemporaryDirectory();
                                      var fileName =
                                          DateTime.now().millisecondsSinceEpoch;
                                      final file = await File(
                                              "${tempDir.path}/$fileName.png")
                                          .create();
                                      file.writeAsBytesSync(editedImage);
                                      controller.content[controller.content
                                              .indexOf(
                                                  controller.content[index])]
                                          ["path"] = file.path;
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: ShapeDecoration(
                                          color: Colors.grey.shade300,
                                          shape: const CircleBorder()),
                                      child: const Icon(Icons.edit,
                                          color: Colors.black, size: 14),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      controller.content
                                          .remove(controller.content[index]);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: ShapeDecoration(
                                          color: Colors.grey.shade300,
                                          shape: const CircleBorder()),
                                      child: const Icon(Icons.remove,
                                          color: Colors.black, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    : UploadTypeVideo(
                        element: controller.content[index],
                        postController: controller);
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kSocialPrimaryColor,
        onPressed: () => controller.openOptionSheet(),
        child: const Icon(Icons.add, color: kBlackColor),
      ),
    );
  }
}

class UploadTypeVideo extends StatefulWidget {
  final Map element;
  final CreatePostController postController;
  const UploadTypeVideo(
      {super.key, required this.element, required this.postController});

  @override
  State<UploadTypeVideo> createState() => _UploadTypeVideoState();
}

class _UploadTypeVideoState extends State<UploadTypeVideo> {
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    videoPlayerController =
        VideoPlayerController.file(File(widget.element["path"]))
          ..initialize().then((_) {
            videoPlayerController.pause();
            setState(() {});
          });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.width - 20,
      margin: const EdgeInsets.only(bottom: 15),
      width: context.width - 20,
      child: videoPlayerController.value.isInitialized
          ? Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Wrap(
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.postController.content.remove(widget.element);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: ShapeDecoration(
                              color: Colors.grey.shade300,
                              shape: const CircleBorder()),
                          child: const Icon(Icons.remove,
                              color: Colors.black, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (videoPlayerController.value.isPlaying) {
                      videoPlayerController.pause();
                    } else {
                      videoPlayerController.play();
                    }
                    setState(() {});
                  },
                  icon: Icon(
                      videoPlayerController.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      size: 35,
                      color: kWhiteColor),
                ),
              ],
            )
          : customCircularProgress(strokeColor: kPrimaryColor),
    );
  }
}
