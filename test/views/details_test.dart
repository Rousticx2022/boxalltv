import 'package:boxalltv/controllers/details_controller.dart';
import 'package:boxalltv/views/details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:boxalltv/utils/collections.dart';
import '../utils/mock_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  const String testUid = 'user123';
  const String testVid = 'video123';

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uid': testUid});
    fakeFirestore = FakeFirebaseFirestore();
    videosCollection = fakeFirestore.collection('videos');
    usersCollection = fakeFirestore.collection('users');
    Get.testMode = true;
    
    // Create the video doc to prevent errors
    await videosCollection.doc(testVid).set({
      'title': 'Test Movie',
      'url': 'http://test.com/video.mp4',
    });

    Get.put(DetailsController(vid: testVid));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Details UI renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Details(vid: testVid),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
