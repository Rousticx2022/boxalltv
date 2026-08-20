import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/advertiser_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/styles.dart';
import 'publish_ad.dart';

class Advertiser extends GetView<AdvertiserController> {
  const Advertiser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Advertiser Panel"),
        actions: [
          Center(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: kWhiteColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: IconButton(
                onPressed: () => {},
                color: const Color(0xfff71735),
                icon: Icon(Icons.edit, size: 18.sp),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(
        () => controller.loadingStats.value
            ? customCircularProgress(strokeColor: kButtonColor)
            : controller.pendingAds.isEmpty || controller.publishedAds.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("You have ads\npublished yet.",
                            style: fontPoppins(fontSize: 40)),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            await Get.to(() => const PublishAd(),
                                transition: Transition.cupertino);
                            controller.getUserAds();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 15),
                            decoration: const ShapeDecoration(
                              shape: StadiumBorder(),
                              gradient: LinearGradient(
                                colors: [Color(0xffdb3445), Color(0xfff71735)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Publish your Ad",
                              style: fontPoppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: kWhiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        tileColor: kWhiteColor.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        title: Text("${controller.publishedAds.length}",
                            style: fontPoppins(fontSize: 22.sp)),
                        subtitle: Text("Published Ads",
                            style: fontPoppins(fontSize: 18.sp)),
                        trailing: IconButton(
                          onPressed: () => Get.to(() => const PublishAd(),
                              transition: Transition.cupertino),
                          icon: const Icon(Icons.add, color: kWhiteColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: kWhiteColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${controller.advertiserData["totalAds"]}",
                                        style: fontPoppins(fontSize: 17.sp)),
                                    Text("Total Ads",
                                        style: fontPoppins(fontSize: 15.sp)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: kWhiteColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${controller.advertiserData["totalViews"]}",
                                        style: fontPoppins(fontSize: 17.sp)),
                                    Text("Total Views",
                                        style: fontPoppins(fontSize: 15.sp)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text("On Going Ads", style: fontPoppins(fontSize: 18.sp)),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.publishedAds.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            leading: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: kWhiteColor.withValues(alpha: 0.5),
                                    width: 1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: controller.publishedAds[index]
                                      ["logo"],
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title: Text(controller.publishedAds[index]["title"],
                                maxLines: 1,
                                style: fontPoppins(fontSize: 17.sp)),
                            subtitle: Text(
                                "Remaining: \$${controller.publishedAds[index]["totalBudget"]}",
                                style: fontPoppins(fontSize: 15.sp)),
                            trailing: Chip(
                              label: Text(
                                  controller.publishedAds[index]["active"]
                                      ? "Active"
                                      : "Paused",
                                  style: fontPoppins(
                                      fontSize: 13.sp,
                                      color: controller.publishedAds[index]
                                              ["active"]
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500)),
                              backgroundColor: kWhiteColor.withValues(alpha: 0.1),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(color: kWhiteColor.withValues(alpha: 0.5));
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}
