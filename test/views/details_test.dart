import 'package:boxalltv/controllers/details_controller.dart';
import 'package:boxalltv/views/details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../helpers/firebase_test_setup.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  const String testUid = 'user123';
  const String testVid = 'video123';

  setUp(() async {
    fakeFirestore = setupFakeFirestore();
    Get.testMode = true;

    Get.parameters = {'uid': testUid, 'vid': testVid};

    // Create the video doc to prevent errors
    await videosCollection.doc(testVid).set({
      'title': 'Test Movie',
      'url': 'http://test.com/video.mp4',
      'genres': [],
      'banner': 'http://test.com/banner.png',
      'poster': 'http://test.com/poster.png',
      'type': 'movie',
      'amount': 0,
    });

    await videoDataCollection.doc(testVid).set({
      'views': 0,
      'likes': [],
      'dislikes': [],
    });

    await usersCollection.doc(testUid).set({'recommendations': []});

    Get.put(DetailsController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Details UI renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return const GetMaterialApp(home: Details());
        },
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
