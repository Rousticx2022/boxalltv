import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class YourChannelController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;
  String uid = Get.find<BottomTabController>().uid!;
  RxMap channelData = {}.obs;
  RxBool loadingStats = true.obs;

  RxInt selectedYear = int.parse(DateFormat("yyyy").format(DateTime.now())).obs;
  RxDouble maxY = 10.0.obs;

  RxMap stats = {
    "january": 0.0,
    "february": 0.0,
    "march": 0.0,
    "april": 0.0,
    "may": 0.0,
    "june": 0.0,
    "july": 0.0,
    "august": 0.0,
    "september": 0.0,
    "october": 0.0,
    "november": 0.0,
    "december": 0.0,
  }.obs;

  TextEditingController nameController = TextEditingController();

  Stream<Map<String, dynamic>> fetchChannelData() {
    Stream stream = creatorsCollection.doc(uid).snapshots();
    return stream.map((event) => {
          "channelName": event["channelName"],
          "totalRevenue": event["totalRevenue"],
          "totalMovies": event["totalMovies"],
          "totalSeries": event["totalSeries"],
          "overallPopularity": event["overallPopularity"],
        });
  }

  void editChannelNameDialog() {
    nameController.text = channelData["channelName"];
    Get.defaultDialog(
      title: "Update Channel Name",
      titleStyle: fontHeading(fontSize: 18.sp, fontWeight: FontWeight.w600),
      content: TextField(
        controller: nameController,
        style: fontBody(),
        decoration: InputDecoration(
            hintText: "Enter channel name",
            hintStyle: fontBody(),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: kWhiteColor)),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kWhiteColor)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kWhiteColor))),
      ),
      backgroundColor: kGreyColor2,
      textCancel: "Cancel",
      textConfirm: "Update",
      onConfirm: () {
        if (nameController.text.isEmpty) return;

        creatorsCollection.doc(uid).update({
          "channelName": nameController.text,
        });

        Get.back();
        customSnackBar(text: "Channel name updated");
      },
      confirmTextColor: kWhiteColor,
      cancelTextColor: kButtonColor,
      buttonColor: kButtonColor,
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: kWhiteColor,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    final style = fontBody(
      color: kWhiteColor,
      fontWeight: FontWeight.w500,
      fontSize: 14.sp,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      space: 3,
      meta: meta,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(show: false);

  LinearGradient barsGradient = const LinearGradient(
    colors: [
      kPrimaryColor,
      kWhiteColor,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  Future<void> fetchMonthlyViews() async {
    loadingStats.value = true;
    stats = {
      "january": 0.0,
      "february": 0.0,
      "march": 0.0,
      "april": 0.0,
      "may": 0.0,
      "june": 0.0,
      "july": 0.0,
      "august": 0.0,
      "september": 0.0,
      "october": 0.0,
      "november": 0.0,
      "december": 0.0,
    }.obs;
    QuerySnapshot videos = await videosCollection
        .where("active", isEqualTo: true)
        .where("creatorID", isEqualTo: uid)
        .get();

    for (DocumentSnapshot video in videos.docs) {
      QuerySnapshot months = await videoDataCollection
          .doc(video.id)
          .collection("statistics")
          .where("year", isEqualTo: selectedYear.value)
          .get();

      for (DocumentSnapshot month in months.docs) {
        stats[month["month"].toLowerCase()] += month["views"].toDouble();
      }
    }
    double maxVal = 0.0;

    stats.forEach((k, v) {
      if (v > maxVal) {
        maxVal = v;
      }
    });
    maxY.value = maxVal;
    loadingStats.value = false;
  }

  @override
  void onInit() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: animationController);
    animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    channelData.bindStream(fetchChannelData());
    fetchMonthlyViews();
    super.onInit();
  }

  @override
  void dispose() {
    nameController.dispose();
    animationController.dispose();
    super.dispose();
  }
}
