import 'package:fl_chart/fl_chart.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:boxalltv/views/channel/add_movie.dart';
import 'package:boxalltv/views/channel/add_series.dart';
import 'package:boxalltv/views/channel/your_movies.dart';
import 'package:boxalltv/views/channel/your_series.dart';
import 'package:get/get.dart';
import 'package:numeral/numeral.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/your_channel_controller.dart';
import 'estimated_revenue.dart';

class YourChannel extends GetView<YourChannelController> {
  const YourChannel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Obx(() => Text(controller.channelData.isEmpty
            ? "Your Channel"
            : controller.channelData["channelName"])),
        actions: [
          Center(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: kWhiteColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: IconButton(
                onPressed: () => controller.editChannelNameDialog(),
                color: const Color(0xfff71735),
                icon: Icon(Icons.edit, size: 18.sp),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => YourMovies(uid: controller.uid),
                      transition: Transition.cupertino),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.channelData.isEmpty
                                ? "0"
                                : Numeral(controller.channelData["totalMovies"])
                                    .format(fractionDigits: 2),
                            style: fontBody(
                                fontSize: 20.sp, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Movies",
                          style: fontBody(
                              fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => YourSeries(uid: controller.uid),
                      transition: Transition.cupertino),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.channelData.isEmpty
                                ? "0"
                                : Numeral(controller.channelData["totalSeries"])
                                    .format(fractionDigits: 2),
                            style: fontBody(
                                fontSize: 20.sp, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Series",
                          style: fontBody(
                              fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(
                      () => EstimatedRevenue(uid: controller.uid),
                      transition: Transition.cupertino),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.channelData.isEmpty
                                ? "\$0"
                                : "\$${Numeral(controller.channelData["totalRevenue"]).format(fractionDigits: 2)}",
                            style: fontBody(
                                fontSize: 20.sp, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Estimated Revenue",
                          style: fontBody(
                              fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.channelData.isEmpty
                              ? "0"
                              : Numeral(controller
                                      .channelData["overallPopularity"])
                                  .format(fractionDigits: 2),
                          style: fontBody(
                              fontSize: 20.sp, fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Popularity",
                        style: fontBody(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Monthly Total Views",
                  style: fontHeading(
                      fontSize: 16.sp, fontWeight: FontWeight.w600)),
              Obx(
                () => controller.loadingStats.value
                    ? progressIndicator()
                    : Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              controller.selectedYear -= 1;
                              controller.fetchMonthlyViews();
                            },
                            iconSize: 15.sp,
                            icon: const Icon(Icons.arrow_back_ios_new),
                          ),
                          Text("${controller.selectedYear}",
                              style: fontBody(fontSize: 16.sp)),
                          IconButton(
                            onPressed: () {
                              controller.selectedYear += 1;
                              controller.fetchMonthlyViews();
                            },
                            iconSize: 15.sp,
                            icon: const Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const Divider(color: kWhiteColor),
          SizedBox(
            width: context.width - 40,
            height: (context.width - 40) * 3 / 4,
            child: Obx(
              () => BarChart(
                BarChartData(
                  barTouchData: controller.barTouchData,
                  titlesData: controller.titlesData,
                  borderData: controller.borderData,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["january"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["february"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["march"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["april"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["may"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["june"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["july"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 7,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["august"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 8,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["september"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 9,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["october"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 10,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["november"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 11,
                      barRods: [
                        BarChartRodData(
                          toY: controller.stats["december"],
                          gradient: controller.barsGradient,
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  ],
                  gridData: const FlGridData(show: false),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: controller.maxY.value + 2,
                ),
                swapAnimationDuration:
                    const Duration(milliseconds: 150), // Optional
                swapAnimationCurve: Curves.linear, // Optional
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionBubble(
        // Menu items
        items: <Bubble>[
          // Floating action menu item
          Bubble(
            title: "Add Movies",
            iconColor: kWhiteColor,
            bubbleColor: kStreamPrimaryColor,
            icon: Remix.movie_2_fill,
            titleStyle: fontButton(fontSize: 15.sp, color: kWhiteColor),
            onPress: () {
              Get.to(() => AddMovie(uid: controller.uid),
                  transition: Transition.cupertino);
              controller.animationController.reverse();
            },
          ),
          // Floating action menu item
          Bubble(
            title: "Add Series",
            iconColor: kWhiteColor,
            bubbleColor: kStreamPrimaryColor,
            icon: Remix.movie_2_fill,
            titleStyle: fontButton(fontSize: 15.sp, color: kWhiteColor),
            onPress: () {
              Get.to(() => AddSeries(uid: controller.uid),
                  transition: Transition.cupertino);
              controller.animationController.reverse();
            },
          ),
        ],
        iconData: Icons.add,
        onPress: () => controller.animationController.isCompleted
            ? controller.animationController.reverse()
            : controller.animationController.forward(),
        iconColor: kWhiteColor, backGroundColor: kStreamPrimaryColor,
        animation: controller.animation,
      ),
    );
  }
}
