import 'package:boxalltv/utils/collections.dart';
import 'package:get/get.dart';

import 'bottomtab_controller.dart';

class AdvertiserController extends GetxController {
  String uid = Get.find<BottomTabController>().uid!;
  RxMap advertiserData = {}.obs;
  RxBool loadingStats = true.obs;
  RxList publishedAds = [].obs, pendingAds = [].obs;

  Stream<Map<String, dynamic>> fetchChannelData() {
    Stream stream = advertisersCollection.doc(uid).snapshots();
    return stream.map((event) => event.data() as Map<String, dynamic>);
  }

  Future<void> getUserAds() async {
    await customVideoAdsCollection
        .where("uid", isEqualTo: uid)
        .where("status", isEqualTo: "ongoing")
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get()
        .then((value) {
          if (value.docs.isEmpty) return;

          publishedAds.clear();
          publishedAds.addAll(value.docs);
        });

    await customVideoAdsCollection
        .where("uid", isEqualTo: uid)
        .where("status", isEqualTo: "pending")
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get()
        .then((value) {
          if (value.docs.isEmpty) return;

          pendingAds.clear();
          pendingAds.addAll(value.docs);
        });
    loadingStats.value = false;
  }

  @override
  void onInit() {
    advertiserData.bindStream(fetchChannelData());
    getUserAds();
    super.onInit();
  }
}
