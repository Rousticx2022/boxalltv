import 'package:boxalltv/utils/collections.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

FakeFirebaseFirestore setupFakeFirestore() {
  final fakeFirestore = FakeFirebaseFirestore();
  
  avatarsCollection = fakeFirestore.collection("avatars");
  usersCollection = fakeFirestore.collection("users");
  creatorsCollection = fakeFirestore.collection("creators");
  advertisersCollection = fakeFirestore.collection("advertisers");
  chatsCollection = fakeFirestore.collection("chats");
  videosCollection = fakeFirestore.collection("videos");
  customVideoAdsCollection = fakeFirestore.collection("customVideoAds");
  submittedVideosCollection = fakeFirestore.collection("submittedVideos");
  reviewVideosCollection = fakeFirestore.collection("reviewVideos");
  reviewEpisodesCollection = fakeFirestore.collection("reviewEpisodes");
  genresCollection = fakeFirestore.collection("genres");
  livesCollection = fakeFirestore.collection("liveTvs");
  upcomingCollection = fakeFirestore.collection("upcoming");
  videoDataCollection = fakeFirestore.collection("videoData");
  countriesCollection = fakeFirestore.collection("countries");
  targetCountriesCollection = fakeFirestore.collection("targetCountries");
  targetZipcodesCollection = fakeFirestore.collection("targetZipcodes");
  subscriptionsCollection = fakeFirestore.collection("subscriptions");
  ordersCollection = fakeFirestore.collection("orders");
  postsCollection = fakeFirestore.collection("posts");
  postDataCollection = fakeFirestore.collection("postData");
  reelsCollection = fakeFirestore.collection("reels");
  reportTypesCollection = fakeFirestore.collection("reportTypes");
  reelSoundsCollection = fakeFirestore.collection("reel_sounds");
  generalCollection = fakeFirestore.collection("general");
  withdrawsCollection = fakeFirestore.collection("withdraws");

  return fakeFirestore;
}
