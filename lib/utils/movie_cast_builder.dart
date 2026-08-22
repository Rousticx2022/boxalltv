import 'package:auto_size_text/auto_size_text.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'ui_widgets.dart';
import 'placeholder_rails.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'collections.dart';
import 'styles.dart';
import 'package:flutter/material.dart';

class MovieCastBuilder {
  Widget movieCast(String vid) {
    return FutureBuilder<QuerySnapshot>(
      future: videosCollection
          .doc(vid)
          .collection("cast")
          .orderBy("order")
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return PlaceholderRails.instance.buildCastPlaceholder(context);
        }
        List<DocumentSnapshot> castList = snapshot.data!.docs;
        if (snapshot.hasData && castList.isEmpty) return Container();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cast",
                  style: GoogleFonts.cabin(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: castList.length,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 130,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: castList[index]["picture"].isEmpty
                                ? "https://breakingtvfilestore.b-cdn.net/noimage.jpg"
                                : castList[index]["picture"],
                            placeholder: (context, url) =>
                                Image.asset("assets/placeholder3.gif"),
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                          ),
                        ),
                        AutoSizeText(
                          castList[index]["name"],
                          maxLines: 2,
                          minFontSize: 10,
                          textAlign: TextAlign.center,
                          style: customTextStyleBody(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "as ${castList[index]["role"]}",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: customTextStyleBody(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 10),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map>> getTvCrews(String vid) async {
    List<Map> crews = [];
    QuerySnapshot castSnapshot = await videosCollection
        .doc(vid)
        .collection("cast")
        .orderBy("order")
        .get();
    QuerySnapshot crewSnapshot = await videosCollection
        .doc(vid)
        .collection("crew")
        .orderBy("order")
        .get();
    for (DocumentSnapshot element in castSnapshot.docs) {
      crews.add({
        "picture": element["picture"],
        "name": element["name"],
        "role": element["role"],
        "isCast": true,
      });
    }
    for (DocumentSnapshot element in crewSnapshot.docs) {
      crews.add({
        "picture": element["picture"],
        "name": element["name"],
        "position": element["position"],
        "isCast": false,
      });
    }
    return crews;
  }

  Widget movieCastTV(String vid) {
    return FutureBuilder<List<Map>>(
      future: getTvCrews(vid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return PlaceholderRails.instance.buildCastPlaceholder(
            context,
            size: 55,
          );
        }
        if (snapshot.hasData && snapshot.data!.isEmpty) return Container();
        List<Map> crews = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(top: 10),
          height: 102,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const ScrollPhysics(),
            itemCount: crews.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: 110,
                child: MaterialButton(
                  onPressed: () {},
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: crews[index]["picture"].isEmpty
                              ? "https://firebasestorage.googleapis.com/v0/b/frame-f5635.appspot.com/o/noavatar.jpg?alt=media&token=e039fec3-ed48-4ef4-a2d1-73805eab4858"
                              : crews[index]["picture"],
                          placeholder: (context, url) => ColoredBox(
                            color: kWhiteColor.withValues(alpha: 0.15),
                          ),
                          fit: BoxFit.cover,
                          height: 55,
                          width: 55,
                        ),
                      ),
                      AutoSizeText(
                        crews[index]["name"],
                        maxLines: 2,
                        minFontSize: 10,
                        textAlign: TextAlign.center,
                        style: customTextStyleBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      crews[index]["isCast"]
                          ? AutoSizeText(
                              "as ${crews[index]["role"]}",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 8,
                              style: customTextStyleBody(fontSize: 10),
                            )
                          : AutoSizeText(
                              "${crews[index]["position"]}",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 8,
                              style: customTextStyleBody(fontSize: 10),
                            ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 10),
          ),
        );
      },
    );
  }

  Widget movieCrew(String vid) {
    return FutureBuilder<QuerySnapshot>(
      future: videosCollection
          .doc(vid)
          .collection("crew")
          .orderBy("order")
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return PlaceholderRails.instance.buildCrewPlaceholder(context);
        }
        List<DocumentSnapshot> castList = snapshot.data!.docs;
        if (snapshot.hasData && castList.isEmpty) return Container();
        return SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: castList.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: 170,
                child: ListTile(
                  tileColor: kButtonColor.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: castList[index]["picture"].isEmpty
                          ? "https://firebasestorage.googleapis.com/v0/b/frame-f5635.appspot.com/o/noavatar.jpg?alt=media&token=e039fec3-ed48-4ef4-a2d1-73805eab4858"
                          : castList[index]["picture"],
                      placeholder: (context, url) => ColoredBox(
                        color: kWhiteColor.withValues(alpha: 0.15),
                      ),
                      fit: BoxFit.cover,
                      height: 40,
                      width: 40,
                    ),
                  ),
                  title: Text(
                    castList[index]["position"],
                    maxLines: 1,
                    style: customTextStyleBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: AutoSizeText(castList[index]["name"], maxLines: 2),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 10),
          ),
        );
      },
    );
  }
}
