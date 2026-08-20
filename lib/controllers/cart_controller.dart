import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/form_builder.dart';
import '../utils/form_validators.dart';
import '../utils/styles.dart';
import 'package:http/http.dart' as http;

class CartController extends GetxController {
  String? uid = Get.parameters["uid"];
  Map<String, dynamic>? paymentIntent;
  double money = 0.0;
  RxList cartItems = [].obs;
  RxInt pageIndex = 0.obs;
  RxDouble cartTotal = 0.0.obs,
      taxPercentage = 0.0.obs,
      shippingCharge = 0.0.obs,
      subtotal = 0.0.obs;

  RxList pageHeader = [
    "Cart",
    "Shipping Address",
    "Payment Method",
    "Success",
  ].obs;

  RxList pageFooter = [
    "Proceed to Checkout",
    "Go to Payment",
    "Make Payment",
    "Go Back",
  ].obs;

  TextEditingController addressLine1Controller = TextEditingController(),
      addressLine2Controller = TextEditingController(),
      postalCodeController = TextEditingController(),
      stateController = TextEditingController(),
      countryController = TextEditingController(),
      nameController = TextEditingController(),
      contactController = TextEditingController(),
      cityController = TextEditingController();

  PageController pageController = PageController(initialPage: 0);

  RxString selectedAddress = "".obs;
  final formKey = GlobalKey<FormState>();

  Stream<List> fetchCartItems() {
    Stream data = usersCollection
        .doc(uid!)
        .collection("cart")
        .orderBy("lastAdded", descending: true)
        .snapshots();
    return data.map((event) => event.docs.map((e) => e.data()).toList());
  }

  Stream<DocumentSnapshot> fetchProduct(String vid, String productID) {
    return videosCollection
        .doc(vid)
        .collection("products")
        .doc(productID)
        .snapshots();
  }

  Stream<QuerySnapshot> fetchAddresses() {
    return usersCollection
        .doc(uid)
        .collection("addresses")
        .orderBy("mostUsed", descending: true)
        .snapshots();
  }

  void addNewAddress() {
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text("Add address",
                    style: customTextStyleHeadline(
                        fontSize: 18.sp, fontWeight: FontWeight.w600)),
                leading: IconButton(
                  onPressed: () => Get.back(),
                  color: kButtonColor,
                  icon: const Icon(Icons.close),
                ),
              ),
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                    children: [
                      Formbuilder(
                        controller: nameController,
                        validator: fieldValidator,
                        inputType: TextInputType.name,
                        label: "Recipient Name",
                      ).buildTextField(),
                      Formbuilder(
                        controller: contactController,
                        validator: fieldValidator,
                        inputType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        label: "Contact Number",
                      ).buildTextField(),
                      Formbuilder(
                        controller: addressLine1Controller,
                        validator: fieldValidator,
                        inputType: TextInputType.text,
                        label: "House No./ Apartment Name",
                      ).buildTextField(),
                      Formbuilder(
                        controller: addressLine2Controller,
                        validator: fieldValidator,
                        inputType: TextInputType.streetAddress,
                        label: "Street Name/ Lane",
                      ).buildTextField(),
                      Formbuilder(
                        controller: cityController,
                        validator: fieldValidator,
                        inputType: TextInputType.streetAddress,
                        label: "City",
                      ).buildTextField(),
                      Formbuilder(
                        controller: postalCodeController,
                        validator: fieldValidator,
                        inputType: TextInputType.text,
                        label: "Postal Code",
                      ).buildTextField(),
                      Formbuilder(
                        controller: stateController,
                        validator: fieldValidator,
                        inputType: TextInputType.text,
                        label: "State",
                      ).buildTextField(),
                      Formbuilder(
                        controller: countryController,
                        validator: fieldValidator,
                        inputType: TextInputType.text,
                        label: "Country",
                      ).buildTextField(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await usersCollection
                        .doc(uid!)
                        .collection("addresses")
                        .add({
                      "name": nameController.text,
                      "contact": contactController.text,
                      "addressLine1": addressLine1Controller.text,
                      "addressLine2": addressLine2Controller.text,
                      "city": cityController.text,
                      "postalCode": postalCodeController.text,
                      "state": stateController.text,
                      "country": countryController.text,
                      "mostUsed": 0,
                    });
                    Get.back();
                    customSnackBar(text: "Address added successfully");
                    nameController.clear();
                    contactController.clear();
                    addressLine1Controller.clear();
                    addressLine2Controller.clear();
                    cityController.clear();
                    postalCodeController.clear();
                    stateController.clear();
                    countryController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kStreamPrimaryColor,
                    foregroundColor: kWhiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Save",
                      style: fontButton(
                          fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: kBlackColor,
    );
  }

  Future<void> nextButton() async {
    switch (pageIndex.value) {
      case 0:
        if (cartItems.isEmpty) {
          customSnackBar(text: "Your cart is empty");
          return;
        }
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;
      case 1:
        if (selectedAddress.value.isEmpty) {
          customSnackBar(text: "Please select a shipping address");
          return;
        }
        cartTotal.value = 0.0;
        taxPercentage.value = 0.0;
        subtotal.value = 0.0;
        customSnackBar(text: "Processing...");
        for (var item in cartItems) {
          DocumentSnapshot prodDoc = await videosCollection
              .doc(item["vid"])
              .collection("products")
              .doc(item["productID"])
              .get();
          if (!prodDoc.exists) continue;

          cartTotal.value +=
              (prodDoc["mrp"] - (prodDoc["mrp"] * prodDoc["discount"] / 100)) *
                  item["count"];
        }
        taxPercentage.value = (cartTotal * 6 / 100).toPrecision(2);
        shippingCharge.value = 25;
        subtotal.value =
            (cartTotal.value + taxPercentage.value + shippingCharge.value)
                .toPrecision(2);

        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;
      case 2:
        Get.dialog(
          progressIndicator(),
          barrierDismissible: false,
        );
        makePayment(amount: subtotal.value);

        break;
      case 3:
        Get.back();
        break;
    }
  }

  Future<void> makePayment({required double amount}) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.light,
                  merchantDisplayName: 'Frame'))
          .then((value) {});
      displayPaymentSheet(amount);
    } catch (e, s) {
      Get.back();
      customSnackBar(text: 'exception:$e$s');
    }
  }

  Future<dynamic> createPaymentIntent(double amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (amount * 100).toInt().toString(),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer ${const String.fromEnvironment('STRIPE_KEY')}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      Get.back();
      customSnackBar(text: err.toString());
    }
  }

  Future<void> displayPaymentSheet(double amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        await ordersCollection.add({
          "userID": uid,
          "shippingAddress": selectedAddress.value,
          "orderPlaced": {'status': true, 'date': DateTime.now()},
          'outForDelivery': {'status': false, 'date': null},
          'delivered': {'status': false, 'date': null},
          'shipped': {'status': false, 'date': null},
          'cancelled': {'status': false, 'date': null},
          "totalAmountPaid": amount,
          "purchasedAt": DateTime.now(),
          "cartItems": cartItems,
        });
        Get.back();
        customSnackBar(text: "Payment Successful");
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        for (var item in cartItems) {
          await usersCollection
              .doc(uid!)
              .collection("cart")
              .doc("${item["vid"]}_${item["productID"]}")
              .delete();
        }

        paymentIntent = null;
      }).onError((error, stackTrace) {
        Get.back();

        customSnackBar(text: "No Payment Done");
      });
    } on StripeException catch (e) {
      Get.back();
      customSnackBar(text: "${e.error}");
    } catch (e) {
      Get.back();
      customSnackBar(text: '$e');
    }
  }

  @override
  void onInit() {
    cartItems.bindStream(fetchCartItems());
    pageController.addListener(() {
      pageIndex.value = pageController.page!.round();
    });
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    postalCodeController.dispose();
    stateController.dispose();
    cityController.dispose();
    countryController.dispose();
    nameController.dispose();
    contactController.dispose();

    super.onClose();
  }
}
