import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentService {
  static ContentService instance = ContentService();

  void toggleFavourites({
    required String vid,
    required String utilsd,
    required bool status,
  }) async {
    if (status) {
      await usersCollection
          .doc(utilsd)
          .collection("favourites")
          .doc(vid)
          .delete();
      customSnackBar(text: "Removed from favourites");
    } else {
      await usersCollection.doc(utilsd).collection("favourites").doc(vid).set({
        "addedOn": DateTime.now(),
      });
      customSnackBar(text: "Added to favourites");
    }
  }

  void updateGenrePopularity(String genreID) async {
    await genresCollection.doc(genreID).update({
      "popularity": FieldValue.increment(1),
    });
  }

  void contentReports(String vid, String utilsd, String issue) async {
    Get.back();
    await videosCollection.doc(vid).collection("reports").add({
      "utilsd": utilsd,
      "reportDate": DateTime.now(),
      "issue": issue,
    });

    customSnackBar(text: "We will review your issue shortly");
  }

  void shareFeed({required String id, required String page}) async {
    String url = "https://frame-f5635.web.app//#/$page/$id";

    try {
      Share.shareUri(Uri.parse(url));
    } catch (e) {
      customSnackBar(text: e.toString());
    }
  }

  void shareReel({
    required String id,
    required String fileUrl,
    required String page,
  }) async {
    String url = "https://frame-f5635.web.app//#/$page/$id";
    String fileName = DateTime.now().toString();
    try {
      var response = await http.get(Uri.parse(fileUrl));
      final cacheDirectory = (await getExternalStorageDirectory())!.path;
      File imgFile = File('$cacheDirectory/$fileName.png');
      imgFile.writeAsBytesSync(response.bodyBytes);
      Share.shareXFiles([
        XFile('$cacheDirectory/$fileName.png'),
      ], text: "Check out this reel on Frame app. $url");
    } catch (e) {
      customSnackBar(text: e.toString());
    }
  }
}
