part of 'create_reel.dart';

extension _CreateReelStateExt3 on _CreateReelState {
  Widget buildMain(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: _isCameraReady
                ? CameraPreview(cameraController)
                : customCircularProgress(strokeColor: kReelsPrimaryColor),
          ),
          // top section
          Positioned(
            top: kToolbarHeight,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
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
                Visibility(
                  visible: !_isVideoRecording,
                  child: GestureDetector(
                    onTap: () {
                      toggleRecordingMode();
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      margin: const EdgeInsets.only(right: 10),
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        color: Colors.grey.shade900.withValues(alpha: 0.2),
                      ),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Text(
                            "${selectedRecordTimer}s",
                            style: fontBody(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kWhiteColor,
                            ),
                          ),
                          SizedBox(
                            height: 45,
                            width: 45,
                            child: CircularProgressIndicator(
                              value: selectedRecordTimer / 60,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                kWhiteColor,
                              ),
                              backgroundColor: Colors.grey.shade900.withValues(
                                alpha: 0.2,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // side bar
          Visibility(
            visible: !_isVideoRecording,
            child: Positioned(
              right: 10,
              top: context.height / 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(50),
                    bottom: Radius.circular(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: !_isFacingFront,
                      child: IconButton(
                        tooltip: "Toggle Flashlight",
                        onPressed: () => enableFlash(),
                        icon: Icon(
                          _enableFlashlight
                              ? Remix.flashlight_fill
                              : Remix.flashlight_line,
                          size: 30,
                          color: kWhiteColor,
                          shadows: [
                            Shadow(
                              color: kBlackColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      tooltip: "Switch Camera",
                      onPressed: () => toggleCamDirection(),
                      icon: Icon(
                        Remix.refresh_line,
                        size: 30,
                        color: kWhiteColor,
                        shadows: [
                          Shadow(
                            color: kBlackColor.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      tooltip: "Add Music",
                      onPressed: () => openSoundsSheet(),
                      icon: Obx(
                        () => selectedSound.isEmpty
                            ? Icon(
                                Remix.music_2_line,
                                size: 30,
                                color: kWhiteColor,
                                shadows: [
                                  Shadow(
                                    color: kBlackColor.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: selectedSound["thumbnail"],
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                  placeholder: (context, url) => const Icon(
                                    Remix.music_2_line,
                                    size: 50,
                                    color: kWhiteColor,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      tooltip: "Toggle Audio Record",
                      onPressed: () {
                        setState(() {
                          _captureAudioInVideoRecording =
                              !_captureAudioInVideoRecording;
                        });
                        initializeCamera(cameraDirection);
                      },
                      icon: Icon(
                        _captureAudioInVideoRecording
                            ? Remix.mic_fill
                            : Remix.mic_off_fill,
                        size: 30,
                        color: kWhiteColor,
                        shadows: [
                          Shadow(
                            color: kBlackColor.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          // bottom section
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: !_isVideoRecording,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.remove, color: kWhiteColor),
                        Expanded(
                          child: Slider(
                            value: _zoom,
                            max: maxZoom,
                            min: 1,
                            divisions: maxZoom.toInt(),
                            thumbColor: kReelsPrimaryColor,
                            activeColor: kReelsPrimaryColor,
                            inactiveColor: kWhiteColor.withValues(alpha: 0.5),
                            label: "${_zoom.toInt()}",
                            onChanged: (v) {
                              setState(() {
                                _zoom = v;
                              });
                              cameraController.setZoomLevel(_zoom);
                            },
                          ),
                        ),
                        const Icon(Icons.add, color: kWhiteColor),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        color: Colors.grey.shade900.withValues(alpha: 0.2),
                      ),
                      child: IconButton(
                        onPressed: () => pickVideo(),
                        color: kWhiteColor,
                        padding: const EdgeInsets.all(0),
                        icon: const Icon(Remix.gallery_fill),
                      ),
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      color: Colors.transparent,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: AlignmentDirectional.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 4,
                            color: kWhiteColor.withValues(alpha: 0.6),
                            value: 1,
                          ),
                          CircularProgressIndicator(
                            strokeWidth: 4,
                            color: kWhiteColor,
                            value:
                                (1 / (selectedRecordTimer * 1000)) *
                                recordingProgress,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.red.shade700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _isVideoRecording
                                ? stopRecording()
                                : startRecording(),
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isVideoRecording
                                    ? kWhiteColor
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _isVideoRecorded
                        ? Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: Colors.grey.shade900.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () async {
                                // stopRecording();
                              },
                              color: kWhiteColor,
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(Icons.check),
                            ),
                          )
                        : const SizedBox(width: 50),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
