import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference avatarsCollection =
    FirebaseFirestore.instance.collection("avatars");
CollectionReference usersCollection =
    FirebaseFirestore.instance.collection("users");
CollectionReference creatorsCollection =
    FirebaseFirestore.instance.collection("creators");
CollectionReference advertisersCollection =
    FirebaseFirestore.instance.collection("advertisers");
CollectionReference chatsCollection =
    FirebaseFirestore.instance.collection("chats");
CollectionReference videosCollection =
    FirebaseFirestore.instance.collection("videos");
CollectionReference customVideoAdsCollection =
    FirebaseFirestore.instance.collection("customVideoAds");
CollectionReference submittedVideosCollection =
    FirebaseFirestore.instance.collection("submittedVideos");
CollectionReference reviewVideosCollection =
    FirebaseFirestore.instance.collection("reviewVideos");
CollectionReference reviewEpisodesCollection =
    FirebaseFirestore.instance.collection("reviewEpisodes");
CollectionReference genresCollection =
    FirebaseFirestore.instance.collection("genres");
CollectionReference livesCollection =
    FirebaseFirestore.instance.collection("liveTvs");
CollectionReference upcomingCollection =
    FirebaseFirestore.instance.collection("upcoming");
CollectionReference videoDataCollection =
    FirebaseFirestore.instance.collection("videoData");
CollectionReference countriesCollection =
    FirebaseFirestore.instance.collection("countries");
CollectionReference targetCountriesCollection =
    FirebaseFirestore.instance.collection("targetCountries");
CollectionReference targetZipcodesCollection =
    FirebaseFirestore.instance.collection("targetZipcodes");
CollectionReference subscriptionsCollection =
    FirebaseFirestore.instance.collection("subscriptions");
CollectionReference ordersCollection =
    FirebaseFirestore.instance.collection("orders");
CollectionReference postsCollection =
    FirebaseFirestore.instance.collection("posts");
CollectionReference postDataCollection =
    FirebaseFirestore.instance.collection("postData");
CollectionReference reelsCollection =
    FirebaseFirestore.instance.collection("reels");
CollectionReference reportTypesCollection =
    FirebaseFirestore.instance.collection("reportTypes");
CollectionReference reelSoundsCollection =
    FirebaseFirestore.instance.collection("reel_sounds");
CollectionReference generalCollection =
    FirebaseFirestore.instance.collection("general");
CollectionReference withdrawsCollection =
    FirebaseFirestore.instance.collection("withdraws");

const int KEY_UP = 19;
const int KEY_DOWN = 20;
const int KEY_LEFT = 21;
const int KEY_RIGHT = 22;
const int KEY_BACK = 4;
const int KEY_CENTER = 23;
const int KEY_ENTER = 66;
const int KEY_BACKSPACE = 67;
const int KEY_MEDIA_PLAY_PAUSE = 85;
const int KEY_MEDIA_PLAY = 126;
const int KEY_MEDIA_PAUSE = 127;
const int KEY_MEDIA_REWIND = 89;
const int KEY_MEDIA_FAST_FORWARD = 90;
