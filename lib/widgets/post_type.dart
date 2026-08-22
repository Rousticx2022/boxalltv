import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:boxalltv/utils/ui_widgets.dart';

class PostTypeImage extends StatefulWidget {
  final Map content;
  const PostTypeImage({super.key, required this.content});

  @override
  State<PostTypeImage> createState() => _PostTypeImageState();
}

class _PostTypeImageState extends State<PostTypeImage> {
  bool coverFit = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.content["url"],
          placeholder: (c, s) => DecoratedBox(
            decoration: const BoxDecoration(color: kBlackColor),
            child: customCircularProgress(strokeColor: kPrimaryColor),
          ),
          errorWidget: (c, s, v) => DecoratedBox(
            decoration: const BoxDecoration(color: kBlackColor),
            child: customCircularProgress(strokeColor: kPrimaryColor),
          ),
          fit: coverFit ? BoxFit.cover : BoxFit.contain,
          height: Get.width,
          width: Get.width,
        ),
        Positioned(
          right: 10,
          top: 10,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: const CircleBorder(
                side: BorderSide(color: kWhiteColor, width: 0.5),
              ),
              color: kBlackColor.withValues(alpha: 0.5),
            ),
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(45 / 360),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    coverFit = !coverFit;
                  });
                },
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
                icon: Icon(
                  coverFit ? Icons.unfold_less : Icons.unfold_more,
                  color: kWhiteColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PostTypeVideo extends StatefulWidget {
  final Map content;
  final String postID;
  const PostTypeVideo({super.key, required this.content, required this.postID});

  @override
  State<PostTypeVideo> createState() => _PostTypeVideoState();
}

class _PostTypeVideoState extends State<PostTypeVideo> {
  late VideoPlayerController videoPlayerController;

  bool showIconButton = true;

  Future<void> initializeVideo() async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.content["url"]))
          ..initialize().then((_) {
            videoPlayerController.pause();
            if (!mounted) return;
            setState(() {});
          });
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isPlaying) {
        Future.delayed(const Duration(seconds: 2), () {
          showIconButton = false;
          if (!mounted) return;
          setState(() {});
        });
      } else {
        showIconButton = true;
        if (!mounted) return;
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    initializeVideo();
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.removeListener(() {});
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.postID),
      onVisibilityChanged: (VisibilityInfo info) {
        print(info.visibleFraction);
        if (info.visibleFraction == 0) {
          videoPlayerController.pause();
        }
        if (!mounted) return;
        setState(() {});
      },
      child: videoPlayerController.value.isInitialized
          ? GestureDetector(
              onTap: () {
                if (videoPlayerController.value.isPlaying) {
                  videoPlayerController.pause();
                } else {
                  videoPlayerController.play();
                }
                if (!mounted) return;
                setState(() {});
              },
              child: Container(
                height: Get.width / videoPlayerController.value.aspectRatio,
                width: Get.width,
                color: kBlackColor,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Positioned.fill(
                      child: AspectRatio(
                        aspectRatio: videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(videoPlayerController),
                      ),
                    ),
                    if (showIconButton)
                      IconButton(
                        onPressed: () {
                          if (videoPlayerController.value.isPlaying) {
                            videoPlayerController.pause();
                          } else {
                            videoPlayerController.play();
                          }
                          if (!mounted) return;
                          setState(() {});
                        },
                        icon: Icon(
                          videoPlayerController.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 40,
                          color: kPrimaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Container(
              height: Get.width,
              width: Get.width,
              color: kBlackColor,
              child: customCircularProgress(strokeColor: kPrimaryColor),
            ),
    );
  }
}
