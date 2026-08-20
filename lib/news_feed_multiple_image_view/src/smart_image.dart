import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:boxalltv/utils/ui_widgets.dart';

class SmartImage extends StatelessWidget {
  final String src;
  final BoxFit? fit;
  final bool isPost;
  final double? radius;

  const SmartImage(this.src,
      {super.key, this.fit, this.isPost = false, this.radius});

  bool networkImage() => src.startsWith('https');
  //bool base64() => src.contains('[]');

  @override
  Widget build(BuildContext context) {
    return networkImage()
        ? FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: src,
            fit: fit,
            imageErrorBuilder: (_, e, a) {
              return Container(
                alignment: Alignment.center,
                child: const Text(
                  "Error. Please check your internet connection",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          )
        : isPost
            ? Image.file(
                File(src),
                fit: fit,
              )
            : CircleAvatar(
                radius: radius,
                backgroundImage: MemoryImage(
                  imageDecoder(src),
                  //fit: fit,
                ),
              );
  }

  Uint8List imageDecoder(String image) {
    final List<int> list = List<int>.from(jsonDecode(image));
    return Uint8List.fromList(list);
  }
}

class SmartVideo extends StatefulWidget {
  final String src;
  final bool isPost;
  const SmartVideo({super.key, required this.src, required this.isPost});

  @override
  State<SmartVideo> createState() => _SmartVideoState();
}

class _SmartVideoState extends State<SmartVideo> {
  late VideoPlayerController videoPlayerController;
  bool networkVideo() => widget.src.startsWith('https');
  @override
  void initState() {
    videoPlayerController = networkVideo()
        ? VideoPlayerController.networkUrl(Uri.parse(widget.src))
        : VideoPlayerController.file(File(widget.src))
      ..initialize().then((_) {
        if (!mounted) return;
        videoPlayerController.pause();
        videoPlayerController.setVolume(1);
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
    return videoPlayerController.value.isInitialized
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
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                AspectRatio(
                  aspectRatio: videoPlayerController.value.aspectRatio,
                  child: VisibilityDetector(
                    key: ObjectKey(videoPlayerController),
                    onVisibilityChanged: (visibilityInfo) {
                      if (visibilityInfo.visibleFraction == 0 && mounted) {
                        videoPlayerController.pause();
                        setState(() {});
                      } else {
                        videoPlayerController.play();
                        setState(() {});
                      }
                    },
                    child: VideoPlayer(videoPlayerController),
                  ),
                ),
                if (!networkVideo() && widget.isPost)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Icon(
                      Remix.video_on_fill,
                      size: 25,
                      color: kWhiteColor,
                      shadows: [
                        BoxShadow(
                          color: kBlackColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 0,
                        )
                      ],
                    ),
                  ),
                if (networkVideo())
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: videoPlayerController.value.isPlaying ? 0 : 1,
                    child: Stack(
                      children: [
                        const Icon(Icons.circle, color: kBlackColor, size: 50),
                        Icon(
                            videoPlayerController.value.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            size: 50,
                            color: kWhiteColor),
                      ],
                    ),
                  ),
              ],
            ),
          )
        : customCircularProgress(strokeColor: kWhiteColor);
  }
}
