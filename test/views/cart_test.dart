import 'package:boxalltv/controllers/cart_controller.dart';
import 'package:boxalltv/views/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  const String testUid = 'user123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    usersCollection = fakeFirestore.collection('users');
    videosCollection = fakeFirestore.collection('videos');
    ordersCollection = fakeFirestore.collection('orders');
    Get.testMode = true;

    Get.parameters = {'uid': testUid};
    Get.put(CartController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Cart UI renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return const GetMaterialApp(home: Cart());
        },
      ),
    );

    await tester.pumpAndSettle();

    // Initial load will show a stream builder. Let's just check the basic scaffold.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Cart'), findsWidgets);
    expect(find.text('Proceed to Checkout'), findsOneWidget);
  });
}
