import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:video_player/video_player.dart';

import 'package:boxalltv/utils/ui_widgets.dart';

class Trailer extends StatefulWidget {
  final String title, video;
  const Trailer({super.key, required this.video, required this.title});
  @override
  _TrailerState createState() => _TrailerState();
}

class _TrailerState extends State<Trailer> {
  late FlickManager flickManager;
  bool videoLoaded = false;

  @override
  void initState() {
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(widget.video),
        //closedCaptionFile: loadCaptions(lessonDoc["subtitle"]),
      ),
      autoPlay: false,
      autoInitialize: true,
    );
    setState(() {
      videoLoaded = true;
    });
    flickManager.flickControlManager!.enterFullscreen();
    flickManager.flickControlManager!.play();

    super.initState();
  }

  @override
  void dispose() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: videoLoaded
          ? FlickVideoPlayer(
              flickManager: flickManager,
              flickVideoWithControls: FlickVideoWithControls(
                controls: customControls(),
                videoFit: BoxFit.fitWidth,
              ),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                controls: customControls(),
              ),
            )
          : customCircularProgress(strokeColor: kStreamPrimaryColor),
    );
  }

  Stack customControls() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: FlickAutoHideChild(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: const ShapeDecoration(
                          shape: CircleBorder(),
                          color: Colors.white12,
                        ),
                        child: const FlickPlayToggle(size: 55),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(widget.title,
                            style: customTextStyleBody(
                                fontSize: 20, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Row(
                        children: [
                          FlickCurrentPosition(fontSize: 15),
                          Text(' / ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          FlickTotalDuration(fontSize: 15),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      const FlickSubtitleToggle(
                        size: 20,
                        padding: EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: Colors.white12,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const FlickSoundToggle(
                        size: 20,
                        padding: EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: Colors.white12,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const FlickFullScreenToggle(
                        size: 20,
                        padding: EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: Colors.white12,
                        ),
                      ),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 10,
                      handleRadius: 10,
                      curveRadius: 50,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      playedColor: kStreamPrimaryColor,
                      handleColor: kStreamPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
