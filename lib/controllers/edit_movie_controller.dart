import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/collections.dart';
import '../utils/exceptions.dart';
import '../utils/ui_widgets.dart';

class EditMovieController extends GetxController {
  final String uid;
  final String videoID;

  EditMovieController({required this.uid, required this.videoID});

  RxList selectedGenres = [].obs;
  RxBool loading = false.obs;
  RxString selectedType = "FREE".obs;

  final formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController(),
      storylineController = TextEditingController(),
      durationController = TextEditingController(),
      releaseYearController = TextEditingController(),
      genresController = TextEditingController(),
      amountController = TextEditingController(),
      validityController = TextEditingController(),
      contentUrlController = TextEditingController(),
      ratingController = TextEditingController(text: "12+");

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  @override
  void onClose() {
    titleController.dispose();
    storylineController.dispose();
    durationController.dispose();
    releaseYearController.dispose();
    ratingController.dispose();
    genresController.dispose();
    amountController.dispose();
    validityController.dispose();
    contentUrlController.dispose();
    super.onClose();
  }

  Future<void> getData() async {
    loading.value = true;
    try {
      final snapshot = await videosCollection.doc(videoID).get();
      if (snapshot.exists) {
        titleController.text = snapshot['title'] ?? '';
        storylineController.text = snapshot['storyline'] ?? '';
        durationController.text = snapshot['duration'] ?? '';
        releaseYearController.text = (snapshot.data() as Map<String, dynamic>).containsKey('publish') ? snapshot['publish'].toString() : '';
        selectedGenres.value = snapshot['genres'] ?? [];
        genresController.text = selectedGenres.join(",");

        if (snapshot['type'] == "PREMIUM") {
          selectedType.value = "PREMIUM";
          amountController.text = snapshot['amount']?.toString() ?? '';
          validityController.text = snapshot['validity']?.toString() ?? '';
        }
      }
    } catch (e) {
      throw AppException("Failed to load movie data", originalException: e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> uploadForm() async {
    if (!formKey.currentState!.validate()) return;
    loading.value = true;
    try {
      await videosCollection.doc(videoID).update({"active": false});

      await reviewVideosCollection.add({
        "originalID": videoID,
        "creatorID": uid,
        "title": titleController.text,
        "storyline": storylineController.text,
        "section": "movies",
        "duration": durationController.text,
        "publish": int.parse(releaseYearController.text),
        "genres": genresController.text.split(","),
        "type": selectedType.value,
        "contentUrl": contentUrlController.text,
        "contentRating": ratingController.text,
        "pricing": {
          "amount": selectedType.value == "PREMIUM" ? double.parse(amountController.text) : 0,
          "validity": selectedType.value == "PREMIUM" ? int.parse(validityController.text) : 0,
        },
        "addedAt": DateTime.now(),
      });
      customSnackBar(text: "Content submitted and waiting for re-verification");
      Get.back();
    } catch (e) {
      customSnackBar(text: "Failed to submit content");
      throw AppException("Failed to update and submit movie", originalException: e);
    } finally {
      loading.value = false;
    }
  }

  void toggleGenre(String genreName) {
    if (selectedGenres.contains(genreName)) {
      selectedGenres.remove(genreName);
    } else {
      selectedGenres.add(genreName);
    }
    genresController.text = selectedGenres.join(",");
  }

  Query getGenresQuery() {
    return genresCollection.orderBy("name");
  }
}
