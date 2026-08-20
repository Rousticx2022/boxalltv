part of 'rails_builder.dart';

extension RailsBuilderExt2 on RailsBuilder {
  Widget buildPopularGenres() {
    return StreamBuilder<QuerySnapshot>(
        stream: genresCollection
            .where("active", isEqualTo: true)
            .orderBy("popularity", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          List<DocumentSnapshot> genreList = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Popular Genres", style: fontBody(fontSize: 17.sp)),
                    const SizedBox(height: 45),
                  ],
                ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: genreList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () => Get.toNamed(
                              "/genre_videos/${genreList[index]["name"]}",
                              parameters: {
                                "genreID": genreList[index].id,
                                "uid": uid
                              }),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xff192231),
                              border: Border(
                                  left: BorderSide(
                                color: kPrimaryColor,
                                width: 1.5,
                              )),
                            ),
                            child: AutoSizeText(genreList[index]["name"],
                                maxLines: 1,
                                style: customTextStyleBody(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(width: 10)),
                ),
              ],
            ),
          );
        });
  }

  Widget buildContinueWatching() {
    return StreamBuilder<QuerySnapshot>(
        stream: usersCollection
            .doc(uid)
            .collection("continueWatching")
            .orderBy("lastPlayed", descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return PlaceholderRails.instance.buildBannerPlaceholder(context);
          }
          List<DocumentSnapshot> data = snapshot.data!.docs;
          if (snapshot.hasData && data.isEmpty) return Container();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Continue watching", style: fontBody(fontSize: 17.sp)),
                  ],
                ),
                Container(
                  height: 20.h + 25,
                  margin: const EdgeInsets.only(top: 10),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return StreamBuilder<DocumentSnapshot>(
                          stream: videosCollection
                              .doc(data[index]["vid"])
                              .snapshots(),
                          builder: (context, vsnapshot) {
                            if (!vsnapshot.hasData) return const SizedBox();
                            DocumentSnapshot vdata = vsnapshot.data!;
                            if (vsnapshot.hasData && !vdata.exists) {
                              return const SizedBox();
                            }
                            return ContainerBuilder(uid: uid)
                                .videoContainer2(context, vdata, data[index]);
                          });
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: 10),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget buildRent() {
    return StreamBuilder<QuerySnapshot>(
        stream: videosCollection
            .where("active", isEqualTo: true)
            .where("type", isEqualTo: "RENT")
            .orderBy("trending")
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return PlaceholderRails.instance.buildBannerPlaceholder(context);
          }
          List<DocumentSnapshot> data = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Available for Rent",
                        style: fontBody(fontSize: 17.sp)),
                    data.length > 7
                        ? TextButton(
                            onPressed: () => Get.toNamed("/view_more/Rent",
                                parameters: {"uid": uid}),
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).iconTheme.color,
                                backgroundColor: kBlackColor),
                            child: const Text("More"),
                          )
                        : const SizedBox(height: 45),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ContainerBuilder(uid: uid)
                          .videoContainer(context, data[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: 10),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget buildByGenres(BuildContext context, String genre, String genreID) {
    return StreamBuilder<QuerySnapshot>(
        stream: videosCollection
            .where("active", isEqualTo: true)
            .where("genres", arrayContains: genre)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Container();
          }
          List videoList = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(genre,
                        style: customTextStyleHeadline(fontSize: 16.sp)),
                    videoList.length > 7
                        ? TextButton(
                            onPressed: () => Get.toNamed("/genre_videos/$genre",
                                parameters: {"genreID": genreID, "uid": uid}),
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).iconTheme.color,
                                backgroundColor: kBlackColor),
                            child: const Text("More"),
                          )
                        : const SizedBox(height: 45),
                  ],
                ),
                SizedBox(
                  height: 13.h * 3 / 2,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: videoList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ContainerBuilder(uid: uid)
                            .videoContainerPortrait(context, videoList[index]);
                      }),
                ),
              ],
            ),
          );
        });
  }

  Widget buildMostViewed() {
    return StreamBuilder<QuerySnapshot>(
        stream: videosCollection
            .where("active", isEqualTo: true)
            .orderBy("views", descending: true)
            .limit(8)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return PlaceholderRails.instance.buildBannerPlaceholder(context);
          }
          List<DocumentSnapshot> data = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Most Viewed", style: fontBody(fontSize: 17.sp)),
                    data.length > 7
                        ? TextButton(
                            onPressed: () => Get.toNamed(
                                "/view_more/Most Viewed",
                                parameters: {"uid": uid}),
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).iconTheme.color,
                                backgroundColor: kBlackColor),
                            child: const Text("More"),
                          )
                        : const SizedBox(height: 45),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ContainerBuilder(uid: uid)
                          .videoContainer(context, data[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: 10),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
