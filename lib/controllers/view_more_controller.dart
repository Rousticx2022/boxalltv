import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../utils/collections.dart';

class ViewMoreController extends GetxController {
  Query? query;
  final String? section = Get.parameters["section"],
      uid = Get.parameters["uid"];

  @override
  void onInit() {
    loadQuery();
    super.onInit();
  }

  void loadQuery() async {
    if (section == "Trending") {
      query = videosCollection
          .where("active", isEqualTo: true)
          .orderBy('trending', descending: true);
    } else if (section == "Most Viewed") {
      query = videosCollection
          .where("active", isEqualTo: true)
          .orderBy("views", descending: true);
    } else if (section == "Most Popular") {
      query = videosCollection
          .where("active", isEqualTo: true)
          .orderBy('popularity', descending: true);
    } else if (section == "Web Series") {
      query = videosCollection
          .where("active", isEqualTo: true)
          .where('type', isEqualTo: 'series');
    }
  }
}
