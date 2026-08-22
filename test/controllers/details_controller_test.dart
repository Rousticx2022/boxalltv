import 'package:boxalltv/controllers/details_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DetailsController controller;
  const String testUid = 'user123';
  const String testVid = 'video123';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    usersCollection = fakeFirestore.collection('users');
    videosCollection = fakeFirestore.collection('videos');
    videoDataCollection = fakeFirestore.collection('videoData');
    Get.testMode = true;

    Get.parameters = {'uid': testUid, 'vid': testVid};
    await usersCollection.doc(testUid).set({'recommendations': []});
    await videosCollection.doc(testVid).set({
      'genres': ['Action'],
    });
    await videoDataCollection.doc(testVid).set({
      'views': 0,
      'likes': [],
      'dislikes': [],
    });

    controller = DetailsController();
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  test(
    'toggleWatchlist should add video to watchlist if it does not exist',
    () async {
      final videoDetails = await fakeFirestore
          .collection('dummy')
          .doc('dummy')
          .set({
            'poster': 'poster.png',
            'title': 'Test Title',
            'type': 'movie',
            'section': 'trending',
          })
          .then((_) => fakeFirestore.collection('dummy').doc('dummy').get());

      await controller.toggleWatchlist(false, videoDetails);

      final watchlistDoc = await usersCollection
          .doc(testUid)
          .collection('watchlist')
          .doc(testVid)
          .get();
      expect(watchlistDoc.exists, true);
      expect(watchlistDoc['title'], 'Test Title');
    },
  );

  test(
    'toggleWatchlist should remove video from watchlist if it exists',
    () async {
      await usersCollection
          .doc(testUid)
          .collection('watchlist')
          .doc(testVid)
          .set({'dummy': 'data'});

      final dummyVideoDetails = await fakeFirestore
          .collection('dummy')
          .doc('dummy')
          .set({'poster': 'a', 'title': 'b', 'type': 'c', 'section': 'd'})
          .then((_) => fakeFirestore.collection('dummy').doc('dummy').get());

      await controller.toggleWatchlist(true, dummyVideoDetails);

      final watchlistDoc = await usersCollection
          .doc(testUid)
          .collection('watchlist')
          .doc(testVid)
          .get();
      expect(watchlistDoc.exists, false);
    },
  );
}
