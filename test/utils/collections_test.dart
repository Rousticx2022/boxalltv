import 'package:boxalltv/utils/collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collections global variables can be mocked', () {
    // Because Dart initializes globals lazily, reading them without Firebase.initializeApp
    // throws an error. We verify they can be safely overridden for tests.
    final fakeFirestore = FakeFirebaseFirestore();

    usersCollection = fakeFirestore.collection('users');
    videosCollection = fakeFirestore.collection('videos');
    ordersCollection = fakeFirestore.collection('orders');
    reelsCollection = fakeFirestore.collection('reels');

    expect(usersCollection.path, 'users');
    expect(videosCollection.path, 'videos');
    expect(ordersCollection.path, 'orders');
    expect(reelsCollection.path, 'reels');
  });
}
