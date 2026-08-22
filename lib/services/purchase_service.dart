import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:boxalltv/utils/ui_widgets.dart';

class PurchaseService extends GetxService {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment({
    required double amount,
    required String uid,
    required String vid,
    required int validity,
  }) async {
    try {
      paymentIntent = await createPaymentIntent(
        amount,
        'USD',
        uid,
        vid,
        validity,
      );
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!['client_secret'],
              style: ThemeMode.light,
              merchantDisplayName: 'Frame',
            ),
          )
          .then((value) {});
      displayPaymentSheet(amount, uid, vid, validity);
    } catch (e, s) {
      Get.back();
      customSnackBar(text: 'exception:$e$s');
    }
  }

  Future<dynamic> createPaymentIntent(
    double amount,
    String currency,
    String uid,
    String vid,
    int validity,
  ) async {
    try {
      Map<String, dynamic> body = {
        'amount': (amount * 100).toInt().toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer ${const String.fromEnvironment('STRIPE_KEY')}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      Get.back();
      customSnackBar(text: err.toString());
    }
  }

  Future<void> displayPaymentSheet(
    double amount,
    String uid,
    String vid,
    int validity,
  ) async {
    try {
      await Stripe.instance
          .presentPaymentSheet()
          .then((value) async {
            await usersCollection
                .doc(uid)
                .collection("purchases")
                .doc(vid)
                .set({
                  "validity": DateTime.now().add(Duration(days: validity)),
                  "amount": amount,
                  "vid": vid,
                  "purchaseDate": DateTime.now(),
                });
            Get.back();
            customSnackBar(text: "Purchased Successfully");

            paymentIntent = null;
          })
          .onError((error, stackTrace) {
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
}
