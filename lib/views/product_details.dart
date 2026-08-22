import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:readmore/readmore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../controllers/bottomtab_controller.dart';
import '../services/user_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';

class ProductDetails extends StatefulWidget {
  final String uid, vid, productID;
  final bool fromCart;
  const ProductDetails({
    super.key,
    required this.uid,
    required this.vid,
    required this.productID,
    this.fromCart = false,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!widget.fromCart)
            GestureDetector(
              onTap: () {
                Get.toNamed("/cart", parameters: {"uid": widget.uid});
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: videosCollection
            .doc(widget.vid)
            .collection("products")
            .doc(widget.productID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return customCircularProgress(strokeColor: kStreamPrimaryColor);
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Center(child: Text("Product not found!"));
          }

          DocumentSnapshot prodDoc = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            children: [
              GestureDetector(
                onTap: () {
                  final imageProvider = Image.network(prodDoc["image"]).image;
                  showImageViewer(
                    context,
                    imageProvider,
                    doubleTapZoomable: true,
                    onViewerDismissed: () {},
                  );
                },
                child: Container(
                  height: context.width * 2 / 3,
                  width: context.width,
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: prodDoc["image"],
                    placeholder: (context, url) => customCircularProgress(
                      strokeColor: context.theme.primaryColor,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    height: context.width * 2 / 3,
                    width: context.width,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                prodDoc["name"],
                maxLines: 2,
                style: customTextStyleHeadline(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "\$${(prodDoc["mrp"] - (prodDoc["mrp"] * prodDoc["discount"] / 100)).toStringAsFixed(2)}",
                style: fontBody(fontSize: 25.sp, fontWeight: FontWeight.w900),
              ),
              Text(
                "MRP: \$${prodDoc["mrp"]}",
                style: fontBody(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: kWhiteColor.withValues(alpha: 0.7),
                ),
              ),
              Divider(color: kWhiteColor.withValues(alpha: 0.8), height: 40),
              Text(
                "Description",
                style: fontBody(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: kWhiteColor,
                ),
              ),
              const SizedBox(height: 5),
              ReadMoreText(
                prodDoc["description"],
                trimLines: 3,
                style: fontBody(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: kWhiteColor,
                ),
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
                moreStyle: fontButton(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                lessStyle: fontButton(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: usersCollection
                    .doc(widget.uid)
                    .collection("cart")
                    .doc("${widget.vid}_${widget.productID}")
                    .snapshots(),
                builder: (context, csnapshot) {
                  if (!csnapshot.hasData) return const SizedBox();

                  if (csnapshot.hasData && csnapshot.data!.exists) {
                    return Container(
                      height: 53,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: kStreamPrimaryColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => UserService.instance.addToCart(
                              uid: widget.uid,
                              vid: widget.vid,
                              productID: widget.productID,
                            ),
                            icon: const Icon(Icons.add_circle),
                          ),
                          Text(
                            csnapshot.data!["count"].toString(),
                            style: fontBody(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                UserService.instance.removeFromCart(
                                  uid: widget.uid,
                                  vid: widget.vid,
                                  productID: widget.productID,
                                ),
                            icon: const Icon(Icons.remove_circle),
                          ),
                        ],
                      ),
                    );
                  }

                  return ElevatedButton(
                    onPressed: () => UserService.instance.addToCart(
                      uid: widget.uid,
                      vid: widget.vid,
                      productID: widget.productID,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kStreamPrimaryColor,
                      foregroundColor: kWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      "Add to Cart",
                      style: fontButton(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
