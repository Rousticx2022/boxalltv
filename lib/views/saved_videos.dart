import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:boxalltv/views/trailer.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../services/ads_service.dart';

class SavedVideos extends StatefulWidget {
  final String uid;
  const SavedVideos({super.key, required this.uid});

  @override
  State<SavedVideos> createState() => _SavedVideosState();
}

class _SavedVideosState extends State<SavedVideos> {
  bool isSelecting = false;
  List<String> selectedVideos = [];

  deleteVideos() async {
    if (selectedVideos.isEmpty) {
      customSnackBar(text: 'Select videos to delete');
      return;
    }
    for (String url in selectedVideos) {
      await usersCollection
          .doc(widget.uid)
          .collection('trimmedVideos')
          .where('url', isEqualTo: url)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
    }
  }

  toggleSelection(bool value, String url) {
    if (value) {
      setState(() {
        selectedVideos.add(url);
      });
    } else {
      setState(() {
        selectedVideos.remove(url);
      });
    }
    if (selectedVideos.length > 2) {
      Get.find<AdsService>().showRewardedAd(1);
    }
  }

  downloadVideos() async {
    if (selectedVideos.isEmpty) {
      customSnackBar(text: 'Select videos to create mashup');
      return;
    }

    if (await Permission.videos.isDenied ||
        await Permission.photos.isDenied ||
        await Permission.mediaLibrary.isDenied) {
      customSnackBar(text: "Storage permission is required to create mashup");
      await [
        Permission.videos,
        Permission.mediaLibrary,
        Permission.photos,
        Permission.bluetooth,
      ].request();
      return;
    }

    Get.dialog(progressIndicator(), barrierDismissible: false);

    final List<File?> downloadedFiles = await FileDownloader.downloadFiles(
      urls: selectedVideos,
      isParallel: true,
      notificationType: NotificationType.all,
    );

    var dir = Platform.isAndroid
        ? await getDownloadsDirectory()
        : await getTemporaryDirectory();

    List convertedPaths = [];

    for (File? file in downloadedFiles) {
      if (file == null) {
        continue;
      }
      String outputPath =
          '${dir!.path}/converted_${DateTime.now().millisecondsSinceEpoch}.ts';

      await FFmpegKit.execute('-i ${file.path} -codec copy $outputPath')
          .then((session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          convertedPaths.add(outputPath);
          await File(file.path).delete();
          // SUCCESS
        } else if (ReturnCode.isCancel(returnCode)) {
          // CANCEL
        } else {
          // ERROR
        }
      });
    }

    String mashupOutputPath =
        '${dir!.path}/mashup_${DateTime.now().millisecondsSinceEpoch}.ts';
    String mashupOutputPathMP4 =
        '${dir.path}/mashup_${DateTime.now().millisecondsSinceEpoch}.mp4';
    // String mashupOutputPathMKV = '${dir.path}/mashup_${DateTime.now().millisecondsSinceEpoch}.mkv';

    await FFmpegKit.execute(
            '-i "concat:${convertedPaths.join("|")}" -codec copy $mashupOutputPath')
        .then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        await FFmpegKit.execute(
                '-i $mashupOutputPath -codec copy $mashupOutputPathMP4')
            .then((session) async {
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            Get.back();
            // Get.off(() => VideoEditor(file: File(mashupOutputPathMP4)));
            Get.offNamed("/create_post", parameters: {
              'uid': widget.uid,
              "path": mashupOutputPathMP4,
              "type": "video"
            });
            // SUCCESS
          } else if (ReturnCode.isCancel(returnCode)) {
            Get.back();

            // CANCEL
          } else {
            Get.back();
            // ERROR
          }
        });
        // SUCCESS
      } else if (ReturnCode.isCancel(returnCode)) {
        Get.back();
        print('CANCEL');
        // CANCEL
      } else {
        Get.back();
        // ERROR
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Videos'),
      ),
      body: FirestoreQueryBuilder<Map<String, dynamic>>(
        query: usersCollection
            .doc(widget.uid)
            .collection('trimmedVideos')
            .orderBy('addedAt', descending: true),
        builder: (context, snapshot, _) {
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                snapshot.fetchMore();
              }

              DocumentSnapshot video = snapshot.docs[index];

              return GridTile(
                header: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isSelecting)
                      Checkbox(
                        value: selectedVideos.contains(video["url"]),
                        checkColor: kStreamPrimaryColor,
                        onChanged: (value) {
                          toggleSelection(value!, video["url"]);
                        },
                      ),
                  ],
                ),
                footer: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(15)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kWhiteColor.withValues(alpha: 0.2),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(15)),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(video["title"],
                          style: fontBody(fontSize: 16.sp)),
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    if (!isSelecting) {
                      Get.to(() =>
                          Trailer(video: video["url"], title: video["title"]));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: kGreyColor2,
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(video["thumbnail"]),
                          fit: BoxFit.cover,
                        )),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        const Icon(Icons.circle, color: kBlackColor),
                        Icon(Icons.play_circle, size: 25.sp),
                      ],
                    ),
                  ),
                ),
              );
            },
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 48.w,
              mainAxisExtent: 48.w,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: kBlackColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: isSelecting
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isSelecting = false;
                            selectedVideos.clear();
                          });
                        },
                        icon: const Icon(Icons.cancel)),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          deleteVideos();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kButtonColor,
                          foregroundColor: kWhiteColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Delete",
                            style: fontButton(
                                fontSize: 15.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isSelecting) {
                            downloadVideos();
                            return;
                          } else {
                            setState(() {
                              isSelecting = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kStreamPrimaryColor,
                          foregroundColor: kWhiteColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Create Mashup",
                            style: fontButton(
                                fontSize: 15.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed: () {
                    if (isSelecting) {
                      downloadVideos();
                      return;
                    } else {
                      setState(() {
                        isSelecting = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kStreamPrimaryColor,
                    foregroundColor: kWhiteColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Select videos",
                      style: fontButton(
                          fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ),
        ),
      ),
    );
  }
}
