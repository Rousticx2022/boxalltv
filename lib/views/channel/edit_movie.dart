import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/form_validators.dart';
import '../../utils/styles.dart';

import '../../controllers/edit_movie_controller.dart';

class EditMovie extends StatefulWidget {
  final String uid, videoID;
  const EditMovie({super.key, required this.uid, required this.videoID});

  @override
  State<EditMovie> createState() => _EditMovieState();
}

class _EditMovieState extends State<EditMovie> {
  late EditMovieController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EditMovieController(uid: widget.uid, videoID: widget.videoID));
  }

  @override
  void dispose() {
    Get.delete<EditMovieController>();
    super.dispose();
  }

  void openGenresDialog() {
    Get.bottomSheet(
      Column(
        children: [
          const SizedBox(height: kToolbarHeight - 30),
          AppBar(
            backgroundColor: kBlackColor,
            title: Text('Select Genres', style: customTextStyleHeadline()),
          ),
          Expanded(
            child: FirestoreListView(
              query: controller.getGenresQuery(),
              loadingBuilder: (c) =>
                  customCircularProgress(strokeColor: kStreamPrimaryColor),
              itemBuilder: (context, snapshot) {
                return Obx(() => ListTile(
                  title: Text(snapshot["name"],
                      style: fontButton(fontSize: 18.sp)),
                  trailing: IconButton(
                    onPressed: () {
                      controller.toggleGenre(snapshot["name"]);
                    },
                    icon: controller.selectedGenres.contains(snapshot["name"])
                        ? const Icon(Icons.check_circle)
                        : const Icon(Icons.circle_outlined),
                  ),
                ));
              },
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: kBlackColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Movie"),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            TextFormField(
              controller: controller.titleController,
              keyboardType: TextInputType.text,
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                labelText: "Title",
                labelStyle:
                    customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: controller.storylineController,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                labelText: "Storyline",
                labelStyle:
                    customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: controller.releaseYearController,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: false, decimal: false),
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                labelText: "Release year",
                labelStyle:
                    customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.durationController,
                    keyboardType: TextInputType.text,
                    style: customTextStyleBody(
                        color: Colors.white, fontSize: 16.sp),
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      labelText: "Screen time",
                      labelStyle: customTextStyleBody(
                          color: kWhiteColor, fontSize: 16.sp),
                    ),
                    validator: fieldValidator,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: controller.ratingController,
                    keyboardType: TextInputType.text,
                    style: customTextStyleBody(
                        color: Colors.white, fontSize: 16.sp),
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      labelText: "Rating",
                      labelStyle: customTextStyleBody(
                          color: kWhiteColor, fontSize: 16.sp),
                    ),
                    validator: fieldValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: controller.genresController,
              maxLines: 2,
              readOnly: true,
              onTap: () => openGenresDialog(),
              keyboardType: TextInputType.multiline,
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                labelText: "Genres",
                labelStyle:
                    customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
              ),
              validator: fieldValidator,
            ),
            const SizedBox(height: 15),
            Obx(() => Wrap(
              children: [
                RadioListTile(
                  value: "FREE",
                  groupValue: controller.selectedType.value,
                  onChanged: (v) {
                    controller.selectedType.value = "FREE";
                  },
                  title: Text("FREE", style: fontBody()),
                ),
                const SizedBox(width: 15),
                RadioListTile(
                  value: "PREMIUM",
                  groupValue: controller.selectedType.value,
                  onChanged: (v) {
                    controller.selectedType.value = "PREMIUM";
                  },
                  title: Text("PREMIUM", style: fontBody()),
                ),
              ],
            )),
            Obx(() => controller.selectedType.value == "PREMIUM" ? const SizedBox(height: 15) : const SizedBox.shrink()),
            Obx(() => controller.selectedType.value == "PREMIUM"
              ? Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.amountController,
                        keyboardType: TextInputType.text,
                        style: customTextStyleBody(
                            color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Amount (dollar)",
                          labelStyle: customTextStyleBody(
                              color: kWhiteColor, fontSize: 16.sp),
                        ),
                        validator: fieldValidator,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: controller.validityController,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        style: customTextStyleBody(
                            color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Validity (days)",
                          labelStyle: customTextStyleBody(
                              color: kWhiteColor, fontSize: 16.sp),
                        ),
                        validator: fieldValidator,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink()),
            const SizedBox(height: 15),
            Text(
                "Please provide these files: 1. Video (HD or 4K), 2. Banner (3:2), 3. Poster (3:4), 4. N.O.C (PDF format), 5. Optional Trailer (HD), 6. Optional Subtitle (srt)\nPlease upload all in a single google drive and share the url here.",
                style: fontBody(
                    fontSize: 15.sp, color: kWhiteColor.withValues(alpha: 0.7))),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller.contentUrlController,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: false, decimal: false),
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                labelText: "Content URL",
                labelStyle:
                    customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
              ),
              validator: fieldValidator,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: kBlackColor,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: Obx(() => controller.loading.value
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customCircularProgress(strokeColor: kPrimaryColor),
                  ],
                )
              : TextButton(
                  onPressed: () => controller.uploadForm(),
                  style: TextButton.styleFrom(
                      backgroundColor: kButtonColor,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: Text("Submit",
                      style: customTextStyleBody(
                          fontWeight: FontWeight.bold, fontSize: 16.sp)),
                )),
        ),
      ),
    );
  }
}
