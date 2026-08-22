import 'package:boxalltv/controllers/cart_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CartController controller;
  const String testUid = 'user123';
  const String testVid = 'video123';
  const String testProductId = 'prod123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    usersCollection = fakeFirestore.collection('users');
    videosCollection = fakeFirestore.collection('videos');
    ordersCollection = fakeFirestore.collection('orders');
    Get.testMode = true;

    Get.parameters = {'uid': testUid};
    controller = CartController();
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  test('fetchProduct should stream product data correctly', () async {
    await videosCollection
        .doc(testVid)
        .collection('products')
        .doc(testProductId)
        .set({'name': 'Test Product', 'mrp': 100});

    final stream = controller.fetchProduct(testVid, testProductId);
    final snapshot = await stream.first;

    expect(snapshot.exists, true);
    expect(snapshot['name'], 'Test Product');
  });

  test('fetchAddresses should stream addresses correctly', () async {
    await usersCollection.doc(testUid).collection('addresses').add({
      'name': 'Test Address',
      'mostUsed': 0,
    });

    final stream = controller.fetchAddresses();
    final snapshot = await stream.first;

    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first['name'], 'Test Address');
  });

  test('nextButton computes cart totals accurately', () async {
    controller.cartItems.add({
      'vid': testVid,
      'productID': testProductId,
      'count': 2,
    });
    controller.selectedAddress.value = 'address123';
    controller.pageIndex.value = 1; // trigger case 1

    await videosCollection
        .doc(testVid)
        .collection('products')
        .doc(testProductId)
        .set(
          {'mrp': 100, 'discount': 10},
        ); // Price = 90. 2 count = 180. Tax = 180 * 0.06 = 10.8. Shipping = 25. Total = 215.8

    try {
      await controller.nextButton();
    } catch (e) {
      // Ignore PageController assertion error and MissingPluginException from fluttertoast
    }

    expect(controller.cartTotal.value, 180.0);
    expect(controller.taxPercentage.value, 10.8);
    expect(controller.shippingCharge.value, 25.0);
    expect(controller.subtotal.value, 215.8);
  });
}
