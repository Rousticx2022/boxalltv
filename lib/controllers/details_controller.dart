import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';

class DetailsController extends GetxController {
  final episodesKey = GlobalKey();
  String? vid = Get.parameters["vid"], uid = Get.parameters["uid"];
  IconData favouriteIcon = Remix.heart_fill;
  var isFavourite = false.obs, isLiked = false.obs, seasonIndex = 0.obs;
  final videoInteraction = {}.obs;
  RxInt selectedSeasonIndex = 1.obs;
  RxList reviews = [].obs;

  @override
  void onInit() {
    videoInteraction.bindStream(fetchInteraction());
    reviews.bindStream(fetchReviews());
    fetchFavouritesStatus();
    updateRecommendation();
    super.onInit();
  }

  Stream<Map> fetchInteraction() {
    Stream<DocumentSnapshot> stream = videoDataCollection.doc(vid).snapshots();

    return stream.map((event) => {
          "views": event["views"],
          "likes": event["likes"],
          "dislikes": event["dislikes"],
        });
  }

  Stream<List> fetchReviews() {
    Stream<QuerySnapshot> stream = videoDataCollection
        .doc(vid)
        .collection("reviews")
        .where("active", isEqualTo: true)
        .orderBy("postDate", descending: true)
        .limit(2)
        .snapshots();

    return stream.map((qShot) => qShot.docs.map((doc) => doc).toList());
  }

  IconData thumbs_up() {
    return videoInteraction["likes"].contains(uid)
        ? Icons.thumb_up_alt
        : Icons.thumb_up_alt_outlined;
  }

  IconData thumbs_down() {
    return videoInteraction["dislikes"].contains(uid)
        ? Icons.thumb_down_alt
        : Icons.thumb_down_alt_outlined;
  }

  Future<void> addRating(String title) async {
    DocumentSnapshot documentSnapshot = await videoDataCollection
        .doc(vid)
        .collection("reviews")
        .doc(uid!)
        .get();

    if (documentSnapshot.exists) {
      customSnackBar(text: "You have already submitted your review");
      return;
    }

    Get.dialog(
      RatingDialog(
        initialRating: 3.0,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: customTextStyleBody(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        message: Text(
          'Please right your thoughts about this',
          textAlign: TextAlign.center,
          style: customTextStyleBody(fontSize: 15.sp),
        ),
        submitButtonText: 'Submit',
        submitButtonTextStyle: customTextStyleBody(
            fontSize: 17.sp, fontWeight: FontWeight.bold, color: kButtonColor),
        commentHint: 'Review here...',
        onCancelled: () => {},
        onSubmitted: (response) async {
          await videoDataCollection
              .doc(vid)
              .collection("reviews")
              .doc(uid!)
              .set({
            "uid": uid!,
            "rating": response.rating,
            "review": response.comment,
            "postDate": DateTime.now(),
            "active": false,
          });
          customSnackBar(text: "Review has been submitted");
        },
      ),
    );
  }

  Future<void> fetchFavouritesStatus() async {
    DocumentSnapshot streamData =
        await usersCollection.doc(uid).collection("favourites").doc(vid).get();
    if (streamData.exists) {
      isFavourite.value = true;
    } else {
      isFavourite.value = false;
    }
  }

  void toggleLike() async {
    if (videoInteraction["likes"].contains(uid)) {
      await videoDataCollection.doc(vid).update({
        "likes": FieldValue.arrayRemove([uid])
      }).then((value) {
        videosCollection.doc(vid).update({"likes": FieldValue.increment(-1)});
      });
    } else if (videoInteraction["dislikes"].contains(uid)) {
      await videoDataCollection.doc(vid).update({
        "dislikes": FieldValue.arrayRemove([uid]),
        "likes": FieldValue.arrayUnion([uid])
      }).then((value) {
        videosCollection
            .doc(vid)
            .update({"dislikes": FieldValue.increment(-1)});
        videosCollection.doc(vid).update({"likes": FieldValue.increment(1)});
      });
    } else {
      await videoDataCollection.doc(vid).update({
        "likes": FieldValue.arrayUnion([uid])
      }).then((value) {
        videosCollection.doc(vid).update({"likes": FieldValue.increment(1)});
      });
    }
  }

  void toggleDisLike() async {
    if (videoInteraction["dislikes"].contains(uid)) {
      await videoDataCollection.doc(vid).update({
        "dislikes": FieldValue.arrayRemove([uid])
      }).then((value) {
        videosCollection.doc(vid).update({"dislikes": FieldValue.increment(1)});
      });
    } else if (videoInteraction["likes"].contains(uid)) {
      await videoDataCollection.doc(vid).update({
        "likes": FieldValue.arrayRemove([uid]),
        "dislikes": FieldValue.arrayUnion([uid])
      }).then((value) {
        videosCollection.doc(vid).update({"likes": FieldValue.increment(-1)});
        videosCollection.doc(vid).update({"dislikes": FieldValue.increment(1)});
      });
    } else {
      await videoDataCollection.doc(vid).update({
        "dislikes": FieldValue.arrayUnion([uid])
      }).then((value) {
        videosCollection.doc(vid).update({"dislikes": FieldValue.increment(1)});
      });
    }
  }

  Future<void> updateRecommendation() async {
    DocumentSnapshot vdoc = await videosCollection.doc(vid).get();
    DocumentSnapshot udoc = await usersCollection.doc(uid).get();

    List recommendations = udoc["recommendations"];

    recommendations.insertAll(0, vdoc["genres"]);
    recommendations = recommendations.toSet().toList();
    if (recommendations.length > 10) {
      recommendations.sublist(0, 9);
    }

    await usersCollection.doc(uid).update({"recommendations": recommendations});
  }

  Future<void> loadAllReviews() async {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.only(
            top: kToolbarHeight, left: 20, right: 20, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("All Reviews",
                style: GoogleFonts.cabin(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.black,
    );
  }

  Stream<DocumentSnapshot> fetchVideoDetails() {
    return videosCollection.doc(vid).snapshots();
  }

  Stream<DocumentSnapshot> fetchWatchlistStatus() {
    return usersCollection.doc(uid).collection("watchlist").doc(vid).snapshots();
  }

  Future<void> toggleWatchlist(bool exists, DocumentSnapshot videoDetails) async {
    if (exists) {
      await usersCollection.doc(uid).collection("watchlist").doc(vid).delete();
    } else {
      await usersCollection.doc(uid).collection("watchlist").doc(vid).set({
        "addedAt": DateTime.now(),
        "poster": videoDetails["poster"],
        "title": videoDetails["title"],
        "type": videoDetails["type"],
        "section": videoDetails["section"],
      });
    }
  }

  Stream<QuerySnapshot> fetchRelatedVideos(List genres) {
    return videosCollection
        .where("active", isEqualTo: true)
        .where("id", isNotEqualTo: vid)
        .where("genres", arrayContainsAny: genres)
        .limit(6)
        .snapshots();
  }
}
