import 'package:boxalltv/controllers/upload_video_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/exceptions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../helpers/firebase_test_setup.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UploadVideoController controller;
  const String testUid = 'user123';

  setUp(() {
    fakeFirestore = setupFakeFirestore();
    Get.testMode = true;

    controller = UploadVideoController(uid: testUid);
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  test('createReel throws AppException on invalid paths', () async {
    // Because we use invalid paths, FTP upload will fail and should throw AppException
    final captionController = TextEditingController(text: 'My Test Caption');

    expect(
      () => controller.createReel(
        fileName: 'test_file',
        videoPath: 'invalid_video_path.mp4',
        thumbnailImagePath: 'invalid_thumb.jpg',
        captionController: captionController,
        selectedSound: {},
      ),
      throwsA(isA<AppException>()),
    );
  });
}
