import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../services/upload_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/styles.dart';

class AddReelDetails extends StatefulWidget {
  final String videoPath;
  final Map audioData;
  const AddReelDetails({
    super.key,
    required this.videoPath,
    required this.audioData,
  });

  @override
  State<AddReelDetails> createState() => _AddReelDetailsState();
}

class _AddReelDetailsState extends State<AddReelDetails> {
  String thumbnail = "";
  final TextEditingController captionController = TextEditingController();
  bool enableComment = true, enableSharing = true;

  Future<void> getThumbnail() async {
    thumbnail = (await VideoThumbnail.thumbnailFile(
      video: widget.videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxWidth:
          540, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 50,
    ))!;

    setState(() {});
  }

  Future<bool> mergeAudioAndVideo(
    String videoPath,
    String audioPath,
    String outputPath,
  ) async {
    return false;
  }

  @override
  void initState() {
    getThumbnail();
    super.initState();
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Container(
          height: 45,
          width: 45,
          margin: const EdgeInsets.only(left: 10),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: Colors.grey.shade900.withValues(alpha: 0.2),
          ),
          child: IconButton(
            onPressed: () {
              Get.back();
            },
            color: kWhiteColor,
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        backgroundColor: kBlackColor,
        title: const Text("Upload Reel"),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumbnail.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(thumbnail),
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: captionController,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  style: fontBody(fontSize: 16, color: kWhiteColor),
                  decoration: InputDecoration(
                    hintText: "Add a caption",
                    hintStyle: fontBody(fontSize: 16, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 40, color: kWhiteColor.withValues(alpha: 0.5)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Remix.message_2_fill,
              color: kReelsPrimaryColor,
            ),
            title: Text(
              "Enable comments",
              style: fontBody(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kWhiteColor,
              ),
            ),
            trailing: Switch(
              value: enableComment,
              onChanged: (value) {
                setState(() {
                  enableComment = value;
                });
              },
              inactiveTrackColor: Colors.grey.shade900,
              activeTrackColor: kWhiteColor,
              activeThumbColor: kReelsPrimaryColor,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Remix.share_forward_fill,
              color: kReelsPrimaryColor,
            ),
            title: Text(
              "Enable sharing",
              style: fontBody(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kWhiteColor,
              ),
            ),
            trailing: Switch(
              value: enableSharing,
              onChanged: (value) {
                setState(() {
                  enableSharing = value;
                });
              },
              inactiveTrackColor: Colors.grey.shade900,
              activeTrackColor: kWhiteColor,
              activeThumbColor: kReelsPrimaryColor,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: kBlackColor,
        child: ElevatedButton(
          onPressed: () async {
            if (widget.audioData.isNotEmpty) {
              Get.dialog(
                customCircularProgress(strokeColor: kReelsPrimaryColor),
                barrierDismissible: false,
              );
              final File? downloadedFile = await FileDownloader.downloadFile(
                url: widget.audioData["audio"],
                name: "audio_${DateTime.now().millisecondsSinceEpoch}.mp3",
                downloadDestination: DownloadDestinations.publicDownloads,
                notificationType: NotificationType.progressOnly,
              );
              if (downloadedFile == null) {
                Get.back();
                customSnackBar(text: "Please try again");
                return;
              }
              String outputPath =
                  "/storage/emulated/0/Download/merged_${DateTime.now().millisecondsSinceEpoch}.mp4";

              final command =
                  '-i ${widget.videoPath} -i ${downloadedFile.path} -map 0:v:0 -map 1:a:0 -c:v copy -shortest -y $outputPath';
              await FFmpegKit.executeAsync(command).then((session) async {
                final returnCode = await session.getReturnCode();

                // File(downloadedFile.path).delete();
                // File(widget.videoPath).delete();

                Get.back();
                Get.back();
                Get.find<UploadService>().uploadReel(
                  videoFile: outputPath,
                  thumbnail: thumbnail,
                  caption: captionController.text,
                  enableComment: enableComment,
                  enableSharing: enableSharing,
                );
              });
            } else {
              Get.back();
              Get.find<UploadService>().uploadReel(
                videoFile: widget.videoPath,
                thumbnail: thumbnail,
                caption: captionController.text,
                enableComment: enableComment,
                enableSharing: enableSharing,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kReelsPrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Upload",
            style: fontBody(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kBlackColor,
            ),
          ),
        ),
      ),
      floatingActionButton: context.mediaQueryViewInsets.bottom == 0
          ? null
          : FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              backgroundColor: kReelsPrimaryColor,
              child: const Icon(
                Icons.keyboard_hide_rounded,
                color: kBlackColor,
              ),
            ),
    );
  }
}
