part of 'edit_recorded_video.dart';

extension _VideoEditorStateExt2 on _VideoEditorState {
  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      outputDirectory: (await getDownloadsDirectory())?.path,
      format: VideoExportFormat.mp4,
      isFiltersEnabled: false,
      // format: VideoExportFormat.gif,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip

      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        _exportingProgress.value = config.getFFmpegProgress(stats.getTime().toInt());
      },
      onError: (e, s) => customSnackBar(text: "Error while exporting video"),
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;
        File(widget.file).delete();

        Get.defaultDialog(
          title: "Share Exported Video",
          titleStyle: fontHeading(fontSize: 16.sp, fontWeight: FontWeight.w600),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offNamed(
                    "/create_post",
                    parameters: {
                      'uid': uid,
                      'vid': widget.vid,
                      "isTrimmed": "trimmed",
                      "path": file.path,
                      "recordingStartedFrom": widget.recordingStartedFrom.toString(),
                      "type": "video",
                    },
                  );
                },
                style: TextButton.styleFrom(backgroundColor: kWhiteColor.withValues(alpha: 0.2), foregroundColor: kWhiteColor),
                child: Text("Frame", style: fontButton()),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  Get.dialog(customCircularProgress(strokeColor: kStreamPrimaryColor), barrierDismissible: false);
                  await Share.shareXFiles([XFile(file.path)], text: 'I took a video clip from Frame.');
                  Get.back();
                },
                style: TextButton.styleFrom(backgroundColor: kWhiteColor.withValues(alpha: 0.2), foregroundColor: kWhiteColor),
                child: Text("Social Media", style: fontButton()),
              ),
              TextButton(
                onPressed: () => Get.find<BottomTabController>().uploadVideoInProfile(file.path),
                style: TextButton.styleFrom(backgroundColor: kWhiteColor.withValues(alpha: 0.2), foregroundColor: kWhiteColor),
                child: Text("Save in profile", style: fontButton()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {
                  File(widget.file).delete();
                  Get.back();
                },
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Leave editor',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () => _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left),
                tooltip: 'Rotate anticlockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right),
                tooltip: 'Rotate clockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (context) => CropPage(controller: _controller))),
                icon: const Icon(Icons.crop),
                tooltip: 'Open crop screen',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: PopupMenuButton(
                tooltip: 'Open export menu',
                icon: const Icon(Icons.save),
                itemBuilder: (context) => [
                  PopupMenuItem(onTap: _exportCover, child: const Text('Export Image')),
                  PopupMenuItem(onTap: _exportVideo, child: const Text('Export video')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
