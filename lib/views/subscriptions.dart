import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../services/user_service.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';
import '../utils/collections.dart';

class Subscriptions extends StatefulWidget {
  final String uid;
  const Subscriptions({super.key, required this.uid});

  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscriptions> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  bool _available = true;
  late ProductDetails _productDetails;
  bool enableSubscription = true;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;

    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        setState(() {
          _purchases.addAll(purchaseDetailsList);
          _listenToPurchaseUpdated(purchaseDetailsList);
        });
      },
      onDone: () {
        _subscription!.cancel();
      },
      onError: (error) {
        _subscription!.cancel();
      },
    );

    _initialize();

    super.initState();
  }

  @override
  void dispose() {
    _subscription!.cancel();
    super.dispose();
  }

  void _initialize() async {
    _available = await _inAppPurchase.isAvailable();

    List<ProductDetails> products = await _getProducts(
      productIds: <String>{"monthly_premium_subscription"},
    );
    print(products);

    setState(() {
      _products = products;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          customSnackBar(
            text: "Please wait for the transaction to get completed...",
          );

          if (purchaseDetails.purchaseID != null) {
            UserService.instance.subscribeUser(uid: widget.uid, days: 28);
          }

          break;
        case PurchaseStatus.error:
          customSnackBar(text: purchaseDetails.error!.toString());
          break;
        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    });
  }

  Future<List<ProductDetails>> _getProducts({
    required Set<String> productIds,
  }) async {
    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
      productIds,
    );

    return response.productDetails;
  }

  void _subscribe({required ProductDetails product}) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Subscriptions', style: customTextStyleHeadline()),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(widget.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _available
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    snapshot.data!['subscribed']
                        ? ListTile(
                            tileColor: kPrimaryColor,
                            leading: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            title: Text(
                              "Subscription is active",
                              style: customTextStyleHeadline(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "Valid till: ${DateFormat("dd MMMM yyyy").format(snapshot.data!['subscriptionDuration'].toDate())}",
                              style: customTextStyleBody(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [kPrimaryColor, kButtonColor],
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _products[index].title.split(" ")[0],
                                  textAlign: TextAlign.center,
                                  style: fontHeading(
                                    fontSize: 25.sp,
                                    color: kWhiteColor,
                                  ),
                                ),
                                Divider(
                                  color: kWhiteColor.withValues(alpha: 0.6),
                                  thickness: 2,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      _products[index].description
                                          .split(",")
                                          .length,
                                      (i) => ListTile(
                                        leading: Icon(
                                          Icons.circle,
                                          color: kWhiteColor,
                                          size: 15.sp,
                                        ),
                                        minLeadingWidth: 0,
                                        title: Text(
                                          _products[index].description.split(
                                            ",",
                                          )[i],
                                          style: fontBody(fontSize: 17.sp),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: _products[index].price.toString(),
                                    style: fontButton(fontSize: 20.sp),
                                    children: [
                                      TextSpan(
                                        text: " /month",
                                        style: fontBody(fontSize: 16.sp),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    if (snapshot.data!['subscribed']) {
                                      customSnackBar(
                                        text: "Subscription is active",
                                      );
                                    } else {
                                      setState(() {
                                        _productDetails = _products[index];
                                      });
                                      _subscribe(product: _products[index]);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kBlackColor,
                                    foregroundColor: kWhiteColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Subscribe Now',
                                    style: fontButton(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const Center(child: Text('The Store Is Not Available'));
        },
      ),
    );
  }
}
