part of 'upload_video.dart';

extension UploadVideoExt on _UploadVideoState {
  Future<void> selectSound() async {
    pauseVideoPlay();
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(top: kToolbarHeight * 3),
          decoration: const BoxDecoration(
            color: kBlackColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                leading: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kReelsPrimaryColor.withValues(alpha: 0.2),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (player.playing) {
                        await player.stop();
                      }
                      Get.back();
                    },
                    icon: const Icon(Remix.close_line),
                    constraints:
                        const BoxConstraints(maxHeight: 35, maxWidth: 35),
                    padding: const EdgeInsets.all(5),
                    color: kWhiteColor,
                  ),
                ),
                title: Text("Pick a sound",
                    style: fontHeading(
                        fontSize: 20,
                        color: kReelsPrimaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: FirestoreListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  query:
                      reelSoundsCollection.orderBy("addedAt", descending: true),
                  emptyBuilder: (context) =>
                      const Center(child: Text("No sound found")),
                  itemBuilder: (context, soundData) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: kWhiteColor.withValues(alpha: 0.1),
                      ),
                      child: ListTile(
                          minLeadingWidth: 0,
                          leading: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Remix.music_2_fill,
                                  size: 15, color: kButtonColor),
                            ],
                          ),
                          title: Text("${soundData["title"]}",
                              style: fontHeading(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            "${soundData["author"]} - ${soundData["duration"]}",
                            style: fontBody(color: kWhiteColor, fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (selectedSound["id"] != soundData.id) {
                                    if (player.playing) {
                                      await player.stop();
                                    }
                                    await player.setUrl(soundData["url"]);
                                    player.play();
                                    selectedSound["id"] = soundData.id;
                                    setState(() {});
                                    return;
                                  }
                                  selectedSound["id"] = "";
                                  await player.stop();
                                },
                                constraints: const BoxConstraints(maxWidth: 30),
                                icon: selectedSound["id"] == soundData.id &&
                                        !soundSelected
                                    ? AnimatedMusicIndicator(
                                        animate: true,
                                        numberOfBars: 4,
                                        size: 0.30,
                                        backgroundColor: Colors.transparent,
                                        barStyle: BarStyle.dash,
                                        roundBars: true,
                                        colors: const [
                                          kButtonColor,
                                          kWhiteColor,
                                          kButtonColor,
                                          kWhiteColor,
                                        ],
                                      )
                                    : const Icon(Remix.disc_line,
                                        size: 18, color: kButtonColor),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () async {
                                  selectedSound = {
                                    "id": soundData.id,
                                    "url": soundData["url"],
                                    "title": soundData["title"],
                                  };
                                  setState(() {
                                    soundSelected = true;
                                  });
                                  if (player.playing) {
                                    player.stop();
                                  }
                                  Get.back();
                                },
                                constraints: const BoxConstraints(maxWidth: 30),
                                icon: const Icon(Remix.arrow_right_circle_fill,
                                    size: 18, color: kButtonColor),
                              ),
                            ],
                          )),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
