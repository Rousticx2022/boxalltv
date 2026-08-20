part of 'create_reel.dart';

extension CreateReelExt on _CreateReelState {
  openSoundsSheet() {
    Get.bottomSheet(
      Container(
        margin: const EdgeInsets.only(top: kToolbarHeight),
        decoration: const BoxDecoration(
          color: kBlackColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              leading: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kWhiteColor.withValues(alpha: 0.1),
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Remix.close_line),
                  constraints:
                      const BoxConstraints(maxHeight: 35, maxWidth: 35),
                  padding: const EdgeInsets.all(5),
                  color: kWhiteColor,
                ),
              ),
              title: Text("Sounds",
                  style: fontBody(
                      fontSize: 20,
                      color: kWhiteColor,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: FirestoreListView(
                  query: reelSoundsCollection.orderBy("title"),
                  itemBuilder: (context, music) {
                    return ListTile(
                      onTap: () {
                        if (selectedSound["id"] == music.id) {
                          selectedSound.value = {};
                          return;
                        }
                        selectedSound.value = {
                          "title": music["title"],
                          "id": music.id,
                          "author": music["author"],
                          "audio": music["url"],
                          "thumbnail": music["thumbnail"],
                        };
                        Get.back();
                      },
                      visualDensity: VisualDensity.compact,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          imageUrl: music["thumbnail"],
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                          placeholder: (context, url) => const Icon(
                              Remix.music_2_line,
                              size: 50,
                              color: kWhiteColor),
                        ),
                      ),
                      title: Text(
                        music["title"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: fontBody(
                            fontSize: 15,
                            color: kWhiteColor,
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            music["author"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: fontBody(
                                fontSize: 13,
                                color: kWhiteColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            "${music["duration"]}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: fontBody(
                                fontSize: 13,
                                color: kWhiteColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.check_circle,
                          color: selectedSound["id"] == music.id
                              ? kReelsPrimaryColor
                              : Colors.transparent),
                    );
                  }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
