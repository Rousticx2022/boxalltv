import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/form_validators.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/styles.dart';

class AddSeries extends StatefulWidget {
  final String uid;
  const AddSeries({super.key, required this.uid});

  @override
  State<AddSeries> createState() => _AddMovieState();
}

class _AddMovieState extends State<AddSeries> {
  List selectedGenres = [];
  bool loading = false;
  String selectedType = "FREE";

  final formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController(),
      storylineController = TextEditingController(),
      seasonsController = TextEditingController(),
      releaseYearController = TextEditingController(),
      genresController = TextEditingController(),
      amountController = TextEditingController(),
      validityController = TextEditingController(),
      contentUrlController = TextEditingController(),
      ratingController = TextEditingController(text: "12+");

  Future<void> uploadForm() async {
    if (!formKey.currentState!.validate()) return;

    submittedVideosCollection.add({
      "creatorID": widget.uid,
      "title": titleController.text,
      "storyline": storylineController.text,
      "section": "movies",
      "seasons": int.parse(seasonsController.text),
      "publish": int.parse(releaseYearController.text),
      "genres": genresController.text.split(","),
      "type": selectedType,
      "contentUrl": contentUrlController.text,
      "contentRating": ratingController.text,
      "pricing": {
        "amount": double.parse(amountController.text),
        "validity": int.parse(validityController.text),
      },
      "addedAt": DateTime.now(),
    });
    customSnackBar(text: "Content submitted and waiting for verification");
    Get.back();
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
            child: StatefulBuilder(builder: (context, setState) {
              return FirestoreListView(
                query: genresCollection.orderBy("name"),
                loadingBuilder: (c) =>
                    customCircularProgress(strokeColor: kStreamPrimaryColor),
                itemBuilder: (context, snapshot) {
                  return ListTile(
                    title: Text(snapshot["name"],
                        style: fontButton(fontSize: 18.sp)),
                    trailing: IconButton(
                      onPressed: () {
                        if (selectedGenres.contains(snapshot["name"])) {
                          selectedGenres.remove(snapshot["name"]);
                          genresController.text = selectedGenres.join(",");
                        } else {
                          selectedGenres.add(snapshot["name"]);
                          genresController.text = selectedGenres.join(",");
                        }
                        setState(() {});
                      },
                      icon: selectedGenres.contains(snapshot["name"])
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.circle_outlined),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: kBlackColor,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    storylineController.dispose();
    seasonsController.dispose();
    releaseYearController.dispose();
    ratingController.dispose();
    genresController.dispose();
    amountController.dispose();
    validityController.dispose();
    contentUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Series', style: customTextStyleHeadline()),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            TextFormField(
              controller: titleController,
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
              controller: storylineController,
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
              controller: releaseYearController,
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
                    controller: seasonsController,
                    keyboardType: TextInputType.number,
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
                      labelText: "Total Seasons",
                      labelStyle: customTextStyleBody(
                          color: kWhiteColor, fontSize: 16.sp),
                    ),
                    validator: fieldValidator,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: ratingController,
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
              controller: genresController,
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
            Wrap(
              children: [
                RadioListTile(
                  value: selectedType,
                  groupValue: "FREE",
                  onChanged: (v) {
                    setState(() {
                      selectedType = "FREE";
                    });
                  },
                  title: Text("FREE", style: fontBody()),
                ),
                const SizedBox(width: 15),
                RadioListTile(
                  value: selectedType,
                  groupValue: "PREMIUM",
                  onChanged: (v) {
                    setState(() {
                      selectedType = "PREMIUM";
                    });
                  },
                  title: Text("PREMIUM", style: fontBody()),
                ),
              ],
            ),
            if (selectedType == "PREMIUM") const SizedBox(height: 15),
            if (selectedType == "PREMIUM")
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: amountController,
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
                      controller: validityController,
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
              ),
            const SizedBox(height: 15),
            Text(
                "Please provide these files: 1. Episodes (HD or 4K), 2. Banner (3:2), 3. Poster (3:4), 4. N.O.C (PDF format), 5. Optional Trailer (HD), 6. Optional Subtitle (srt)\nPlease upload all in a single google drive and share the url here.",
                style: fontBody(
                    fontSize: 15.sp, color: kWhiteColor.withValues(alpha: 0.7))),
            const SizedBox(height: 10),
            TextFormField(
              controller: contentUrlController,
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
          child: loading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customCircularProgress(strokeColor: kPrimaryColor),
                  ],
                )
              : TextButton(
                  onPressed: () => uploadForm(),
                  style: TextButton.styleFrom(
                      backgroundColor: kButtonColor,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: Text("Submit",
                      style: customTextStyleBody(
                          fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ),
        ),
      ),
    );
  }
}
