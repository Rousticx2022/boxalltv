import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/form_validators.dart';

class EditEpisode extends StatefulWidget {
  final String uid, vid, episodeID;
  const EditEpisode({
    super.key,
    required this.uid,
    required this.vid,
    required this.episodeID,
  });

  @override
  State<EditEpisode> createState() => _EditEpisodeState();
}

class _EditEpisodeState extends State<EditEpisode> {
  bool loading = false;
  final formKey = GlobalKey<FormState>();

  DateTime releaseDate = DateTime.now();

  final seasonNoController = TextEditingController(),
      episodeNoController = TextEditingController(),
      episodeNameController = TextEditingController(),
      releaseDateController = TextEditingController(),
      contentUrlController = TextEditingController(),
      durationController = TextEditingController(),
      episodeDescriptionController = TextEditingController();

  Future<void> getData() async {
    setState(() {
      loading = true;
    });
    final snapshot = await videosCollection
        .doc(widget.vid)
        .collection("episodes")
        .doc(widget.episodeID)
        .get();
    seasonNoController.text = snapshot['seasonNo'].toString();
    episodeNoController.text = snapshot['episodeNo'].toString();
    durationController.text = snapshot['duration'];
    releaseDateController.text = DateFormat(
      "dd/MM/yyyy",
    ).format(snapshot['releaseDate'].toDate());
    episodeNameController.text = snapshot['episodeName'];
    episodeDescriptionController.text = snapshot['episodeDescription'];

    setState(() {
      loading = false;
    });
  }

  Future<void> editEpisode() async {
    if (!formKey.currentState!.validate()) return;
    await videosCollection.doc(widget.vid).update({"active": false});

    await reviewEpisodesCollection.add({
      "videoID": widget.vid,
      "episodeID": widget.episodeID,
      "creatorID": widget.uid,
      "episodeName": episodeNameController.text,
      "episodeNo": int.parse(episodeNoController.text),
      "seasonNo": int.parse(seasonNoController.text),
      "releaseDate": releaseDate,
      "contentUrl": contentUrlController.text,
    });
    customSnackBar(text: "Episode submitted and waiting for re-verification");
    Get.back();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    seasonNoController.dispose();
    episodeNoController.dispose();
    episodeDescriptionController.dispose();
    releaseDateController.dispose();
    contentUrlController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Episode")),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: seasonNoController,
                    keyboardType: TextInputType.number,
                    style: customTextStyleBody(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: "Season No.",
                      labelStyle: customTextStyleBody(
                        color: kWhiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    validator: fieldValidator,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: episodeNoController,
                    keyboardType: TextInputType.number,
                    style: customTextStyleBody(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: "Episode No.",
                      labelStyle: customTextStyleBody(
                        color: kWhiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    validator: fieldValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: episodeDescriptionController,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Episode Description (optional)",
                labelStyle: customTextStyleBody(
                  color: kWhiteColor,
                  fontSize: 16.sp,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: releaseDateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    style: customTextStyleBody(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: "Release Date",
                      labelStyle: customTextStyleBody(
                        color: kWhiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    validator: fieldValidator,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    style: customTextStyleBody(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: "Screen Time",
                      labelStyle: customTextStyleBody(
                        color: kWhiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    validator: fieldValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "Please provide these files: 1. Video (HD or 4K), 2. Banner (3:2), 3. Optional Trailer (HD), 4. Optional Subtitle (srt)\nPlease upload all in a single google drive and share the url here.",
              style: fontBody(
                fontSize: 15.sp,
                color: kWhiteColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: contentUrlController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Content URL",
                labelStyle: customTextStyleBody(
                  color: kWhiteColor,
                  fontSize: 16.sp,
                ),
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
                  onPressed: () => editEpisode(),
                  style: TextButton.styleFrom(
                    backgroundColor: kButtonColor,
                    foregroundColor: kWhiteColor,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    "Submit",
                    style: fontButton(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
