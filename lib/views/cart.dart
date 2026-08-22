import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/views/product_details.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/cart_controller.dart';
import '../services/user_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';

class Cart extends GetView<CartController> {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.pageHeader[controller.pageIndex.value]),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kWhiteColor),
          onPressed: () {
            if (controller.pageIndex.value == 0 ||
                controller.pageIndex.value == 3) {
              Get.back();
            } else {
              controller.pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          },
        ),
        actions: const [],
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kGreyColor2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.pageController,
          children: [
            Obx(
              () => controller.cartItems.length.isEqual(0)
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_shopping_cart_outlined,
                            color: kWhiteColor,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cart is empty!',
                            style: fontBody(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        return StreamBuilder<DocumentSnapshot>(
                          stream: controller.fetchProduct(
                            controller.cartItems[index]["vid"],
                            controller.cartItems[index]["productID"],
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();

                            if (snapshot.hasData && !snapshot.data!.exists) {
                              return const SizedBox();
                            }

                            DocumentSnapshot prodDoc = snapshot.data!;

                            return ListTile(
                              onTap: () => Get.to(
                                () => ProductDetails(
                                  uid: controller.uid!,
                                  vid: controller.cartItems[index]["vid"],
                                  productID: prodDoc.id,
                                  fromCart: true,
                                ),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: prodDoc["image"],
                                  placeholder: (context, url) =>
                                      customCircularProgress(
                                        strokeColor: context.theme.primaryColor,
                                      ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        UserService.instance.addToCart(
                                          uid: controller.uid!,
                                          vid: controller
                                              .cartItems[index]["vid"],
                                          productID: controller
                                              .cartItems[index]["productID"],
                                        ),
                                    icon: const Icon(Icons.add_circle),
                                  ),
                                  Text(
                                    controller.cartItems[index]["count"]
                                        .toString(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        UserService.instance.removeFromCart(
                                          uid: controller.uid!,
                                          vid: controller
                                              .cartItems[index]["vid"],
                                          productID: controller
                                              .cartItems[index]["productID"],
                                        ),
                                    icon: const Icon(Icons.remove_circle),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Column(
              children: [
                ListTile(
                  title: Text(
                    "Pick an Address",
                    style: customTextStyleHeadline(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => controller.addNewAddress(),
                    icon: const Icon(Icons.add_circle),
                  ),
                ),
                const Divider(),
                StreamBuilder<QuerySnapshot>(
                  stream: controller.fetchAddresses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return customCircularProgress(
                        strokeColor: kStreamPrimaryColor,
                      );
                    }

                    List<DocumentSnapshot> addresses = snapshot.data!.docs;

                    if (snapshot.hasData && addresses.isEmpty) {
                      return SizedBox(
                        height: context.height / 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/address.png",
                              width: context.width / 3,
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Please add a new address",
                              style: fontBody(
                                fontSize: 14.sp,
                                color: kWhiteColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (BuildContext context, int index) {
                          return Obx(
                            () => GestureDetector(
                              onTap: () => controller.selectedAddress.value =
                                  addresses[index].id,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: kWhiteColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        controller.selectedAddress.value ==
                                            addresses[index].id
                                        ? kWhiteColor
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      addresses[index]["name"],
                                      style: customTextStyleHeadline(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: kWhiteColor,
                                          size: 15.sp,
                                        ),
                                        Text(
                                          addresses[index]["contact"],
                                          style: customTextStyleHeadline(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: kWhiteColor,
                                          size: 15.sp,
                                        ),
                                        Text(
                                          "${addresses[index]["addressLine1"]} ${addresses[index]["addressLine2"]},",
                                          style: customTextStyleHeadline(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "${addresses[index]["city"]} - ${addresses[index]["postalCode"]},",
                                          style: customTextStyleHeadline(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "${addresses[index]["state"]}, ${addresses[index]["country"]}",
                                          style: customTextStyleHeadline(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 15),
                        itemCount: addresses.length,
                      ),
                    );
                  },
                ),
              ],
            ),
            ListView(
              children: [
                Obx(
                  () => ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.cartItems.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<DocumentSnapshot>(
                        stream: controller.fetchProduct(
                          controller.cartItems[index]["vid"],
                          controller.cartItems[index]["productID"],
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();

                          if (snapshot.hasData && !snapshot.data!.exists) {
                            return const SizedBox();
                          }

                          DocumentSnapshot prodDoc = snapshot.data!;

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: prodDoc["image"],
                                placeholder: (context, url) =>
                                    customCircularProgress(
                                      strokeColor: context.theme.primaryColor,
                                    ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
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
                              "Count: ${controller.cartItems[index]["count"]}",
                              style: fontBody(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Text(
                              "\$${controller.cartItems[index]["count"] * (prodDoc["mrp"] - (prodDoc["mrp"] * prodDoc["discount"] / 100))}",
                              style: fontBody(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    "Cart Total",
                    maxLines: 1,
                    style: customTextStyleHeadline(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Obx(
                    () => Text(
                      "\$${controller.cartTotal.value}",
                      style: fontBody(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    "Tax",
                    maxLines: 1,
                    style: customTextStyleHeadline(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Obx(
                    () => Text(
                      "\$${controller.taxPercentage.value}",
                      style: fontBody(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    "Shipping charge",
                    maxLines: 1,
                    style: customTextStyleHeadline(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Obx(
                    () => Text(
                      "\$${controller.shippingCharge.value}",
                      style: fontBody(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  title: Text(
                    "Subtotal",
                    maxLines: 1,
                    style: customTextStyleHeadline(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Obx(
                    () => Text(
                      "\$${controller.subtotal.value}",
                      style: fontBody(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/order_placed.png",
                  width: context.width / 3,
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 30),
                Text(
                  "Order placed successfully",
                  style: fontBody(
                    fontSize: 16.sp,
                    color: kWhiteColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: kBlackColor,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ElevatedButton(
            onPressed: () => controller.nextButton(),
            style: ElevatedButton.styleFrom(
              backgroundColor: kStreamPrimaryColor,
              foregroundColor: kWhiteColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Obx(
              () => Text(
                controller.pageFooter[controller.pageIndex.value],
                style: fontButton(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
