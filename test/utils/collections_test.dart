import 'package:boxalltv/utils/collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_firebase.dart';

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  test('collections should be initialized correctly', () {
    expect(avatarsCollection, isA<CollectionReference>());
    expect(usersCollection, isA<CollectionReference>());
    expect(videosCollection, isA<CollectionReference>());
    expect(ordersCollection, isA<CollectionReference>());
    expect(reelsCollection, isA<CollectionReference>());
    
    expect(avatarsCollection.path, 'avatars');
    expect(usersCollection.path, 'users');
    expect(videosCollection.path, 'videos');
  });
}
