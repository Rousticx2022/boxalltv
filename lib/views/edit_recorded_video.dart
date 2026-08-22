import 'reels/video_editor_widgets.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_editor/video_editor.dart';
import '../services/export_service.dart';

part 'edit_recorded_video_ext2.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({
    super.key,
    required this.file,
    this.recordingStartedFrom = 0,
    this.vid = "",
  });

  final int recordingStartedFrom;
  final String vid;
  final String file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;
  bool loading = true;

  String uid = FirebaseAuth.instance.currentUser!.uid;

  late final VideoEditorController _controller;

  @override
  void initState() {
    super.initState();
    try {
      _controller =
          VideoEditorController.file(
              File(widget.file),
              minDuration: const Duration(seconds: 0),
              maxDuration: const Duration(seconds: 120),
            )
            ..initialize(aspectRatio: 19 / 9)
                .then((_) {
                  setState(() {
                    loading = false;
                  });
                })
                .catchError((error) {
                  _controller.maxDuration = _controller.video.value.duration;
                  Get.back();
                }, test: (e) => e is VideoMinDurationError);
    } catch (e) {
      customSnackBar(text: e.toString());
      Get.back();
    }
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  void _exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      customSnackBar(text: "Error on image exportation initialization.");
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => customSnackBar(text: "Error while exporting image"),
      onCompleted: (cover) {
        if (!mounted) return;
        File(widget.file).delete();

        Get.defaultDialog(
          title: "Share Exported Image",
          titleStyle: fontHeading(fontSize: 16.sp, fontWeight: FontWeight.w600),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(
                    "/create_post",
                    parameters: {
                      'uid': uid,
                      "path": cover.path,
                      "type": "image",
                    },
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: kWhiteColor.withValues(alpha: 0.2),
                  foregroundColor: kWhiteColor,
                ),
                child: Text("Frame", style: fontButton()),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  Share.shareXFiles([
                    XFile(cover.path),
                  ], text: 'I took this picture from Frame.');
                  Get.back();
                },
                style: TextButton.styleFrom(
                  backgroundColor: kWhiteColor.withValues(alpha: 0.2),
                  foregroundColor: kWhiteColor,
                ),
                child: Text("Social Media", style: fontButton()),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: loading
            ? customCircularProgress(strokeColor: kPrimaryColor)
            : SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _topNavBar(),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CropGridViewer.preview(
                                            controller: _controller,
                                          ),
                                          AnimatedBuilder(
                                            animation: _controller.video,
                                            builder: (_, _) => AnimatedOpacity(
                                              opacity: _controller.isPlaying
                                                  ? 0
                                                  : 1,
                                              duration: kThemeAnimationDuration,
                                              child: GestureDetector(
                                                onTap: _controller.video.play,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      CoverViewer(controller: _controller),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      const TabBar(
                                        labelColor: kWhiteColor,
                                        tabs: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Icon(Icons.content_cut),
                                              ),
                                              Text('Trim Video'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Icon(Icons.video_label),
                                              ),
                                              Text('Select Image'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: _trimSlider(),
                                            ),
                                            _coverSelection(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _isExporting,
                                  builder: (_, bool export, Widget? child) =>
                                      AnimatedSize(
                                        duration: kThemeAnimationDuration,
                                        child: export ? child : null,
                                      ),
                                  child: AlertDialog(
                                    title: ValueListenableBuilder(
                                      valueListenable: _exportingProgress,
                                      builder: (_, double value, _) => Text(
                                        "Exporting video ${(value * 100).ceil()}%",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0'),
  ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([_controller, _controller.video]),
        builder: (_, _) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(
              children: [
                Text(formatter(Duration(seconds: pos.toInt()))),
                const Expanded(child: SizedBox()),
                AnimatedOpacity(
                  opacity: _controller.isTrimming ? 1 : 0,
                  duration: kThemeAnimationDuration,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatter(_controller.startTrim)),
                      const SizedBox(width: 10),
                      Text(formatter(_controller.endTrim)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      ),
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
