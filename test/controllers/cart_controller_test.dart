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
    await videosCollection.doc(testVid).collection('products').doc(testProductId).set({
      'name': 'Test Product',
      'mrp': 100,
    });

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
}
