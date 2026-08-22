part of 'watch.dart';

extension WatchExt3 on Watch {
  Widget buildMain(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.onWillPop();
        return Future.value(true);
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        appBar: AppBar(
          title: Obx(
            () => Text(
              controller.title.value,
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: kWhiteColor,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                controller.flickManager.flickControlManager!.pause();
                Get.toNamed("/cart", parameters: {"uid": controller.uid!});
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kBlackColor,
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: GetX<BottomTabController>(
                  builder: (btController) {
                    return btController.unreadNotifications.value == 0
                        ? const Icon(Icons.shopping_cart_outlined)
                        : badges.Badge(
                            position: badges.BadgePosition.topEnd(
                              top: -10,
                              end: -4,
                            ),
                            badgeStyle: badges.BadgeStyle(
                              shape: badges.BadgeShape.circle,
                              badgeColor: kPrimaryColor,
                              padding: const EdgeInsets.all(5),
                              borderRadius: BorderRadius.circular(20),
                              elevation: 0,
                            ),
                            badgeContent: Text(
                              btController.cartItems.toString(),
                              style: fontButton(fontSize: 12),
                            ),
                            child: const Icon(Icons.shopping_cart_outlined),
                          );
                  },
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Obx(
                () => controller.loading.value
                    ? customCircularProgress(
                        strokeColor: context.theme.primaryColor,
                      )
                    : Obx(
                        () => controller.playingVideoAds.value
                            ? FlickVideoPlayer(
                                key: const Key("ads"),
                                flickManager: controller.flickAdsManager,
                                flickVideoWithControls: FlickVideoWithControls(
                                  controls: customAdsControls(context),
                                ),
                                flickVideoWithControlsFullscreen:
                                    FlickVideoWithControls(
                                      controls: customAdsControls(context),
                                    ),
                              )
                            : FlickVideoPlayer(
                                key: const Key("content"),
                                flickManager: controller.flickManager,
                                flickVideoWithControls: FlickVideoWithControls(
                                  controls: customControlsMobile(context),
                                  videoFit: BoxFit.fitWidth,
                                  closedCaptionTextStyle:
                                      GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                flickVideoWithControlsFullscreen:
                                    FlickVideoWithControls(
                                      closedCaptionTextStyle:
                                          GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      controls: customControls(context),
                                    ),
                              ),
                      ),
              ),
            ),
            Obx(
              () => controller.isFullscreen.value
                  ? const SizedBox()
                  : Expanded(
                      child: Obx(
                        () => controller.products.length.isEqual(0)
                            ? Center(
                                child: Text(
                                  "No products available!",
                                  style: fontHeading(),
                                ),
                              )
                            : ListView.builder(
                                itemCount: controller.products.length,
                                itemBuilder: (context, index) {
                                  return StreamBuilder<DocumentSnapshot>(
                                    stream: videosCollection
                                        .doc(controller.vid!)
                                        .collection("products")
                                        .doc(controller.products[index])
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox();
                                      }

                                      if (snapshot.hasData &&
                                          !snapshot.data!.exists) {
                                        return const SizedBox();
                                      }

                                      DocumentSnapshot prodDoc = snapshot.data!;

                                      return ListTile(
                                        onTap: () {
                                          controller
                                              .flickManager
                                              .flickControlManager!
                                              .pause();
                                          Get.to(
                                            () => ProductDetails(
                                              uid: controller.uid!,
                                              vid: controller.vid!,
                                              productID:
                                                  controller.products[index],
                                            ),
                                          );
                                        },
                                        leading: CachedNetworkImage(
                                          imageUrl: prodDoc["image"],
                                          placeholder: (context, url) =>
                                              customCircularProgress(
                                                strokeColor:
                                                    context.theme.primaryColor,
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          height: 50,
                                          width: 50,
                                        ),
                                        title: Text(
                                          prodDoc["name"],
                                          maxLines: 2,
                                          style: customTextStyleHeadline(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "\$${(prodDoc["mrp"] - (prodDoc["mrp"] * prodDoc["discount"] / 100)).toStringAsFixed(2)}",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: StreamBuilder<DocumentSnapshot>(
                                          stream: usersCollection
                                              .doc(controller.uid!)
                                              .collection("cart")
                                              .doc(
                                                "${controller.vid}_${controller.products[index]}",
                                              )
                                              .snapshots(),
                                          builder: (context, csnapshot) {
                                            if (!csnapshot.hasData) {
                                              return const SizedBox();
                                            }

                                            if (csnapshot.hasData &&
                                                csnapshot.data!.exists) {
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () => UserService
                                                        .instance
                                                        .addToCart(
                                                          uid: controller.uid!,
                                                          vid: controller.vid!,
                                                          productID: controller
                                                              .products[index],
                                                        ),
                                                    icon: const Icon(
                                                      Icons.add_circle,
                                                    ),
                                                  ),
                                                  Text(
                                                    csnapshot.data!["count"]
                                                        .toString(),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () => UserService
                                                        .instance
                                                        .removeFromCart(
                                                          uid: controller.uid!,
                                                          vid: controller.vid!,
                                                          productID: controller
                                                              .products[index],
                                                        ),
                                                    icon: const Icon(
                                                      Icons.remove_circle,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }

                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  onPressed: () => UserService
                                                      .instance
                                                      .addToCart(
                                                        uid: controller.uid!,
                                                        vid: controller.vid!,
                                                        productID: controller
                                                            .products[index],
                                                      ),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        kPrimaryColor,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 5,
                                                        ),
                                                    foregroundColor:
                                                        kWhiteColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Add to Cart",
                                                    style: fontButton(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
