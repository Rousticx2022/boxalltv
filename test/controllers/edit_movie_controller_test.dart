import 'package:boxalltv/controllers/edit_movie_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late EditMovieController controller;
  const String testUid = 'user123';
  const String testVideoId = 'video123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    videosCollection = fakeFirestore.collection('videos');
    reviewVideosCollection = fakeFirestore.collection('reviewVideos');
    genresCollection = fakeFirestore.collection('genres');
    Get.testMode = true;
    
    controller = EditMovieController(uid: testUid, videoID: testVideoId);
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  test('getData should fetch and populate data', () async {
    await videosCollection.doc(testVideoId).set({
      'title': 'Test Movie',
      'storyline': 'Test Story',
      'duration': '120 min',
      'publish': 2023,
      'genres': ['Action', 'Comedy'],
      'type': 'PREMIUM',
      'amount': 5.0,
      'validity': 30,
    });

    await controller.getData();

    expect(controller.titleController.text, 'Test Movie');
    expect(controller.storylineController.text, 'Test Story');
    expect(controller.durationController.text, '120 min');
    expect(controller.releaseYearController.text, '2023');
    expect(controller.selectedGenres.toList(), ['Action', 'Comedy']);
    expect(controller.selectedType.value, 'PREMIUM');
    expect(controller.amountController.text, '5.0');
    expect(controller.validityController.text, '30');
  });
}
