import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../utils/collections.dart';
import 'edit_movie.dart';

class YourMovies extends StatefulWidget {
  final String uid;
  const YourMovies({super.key, required this.uid});

  @override
  State<YourMovies> createState() => _YourMoviesState();
}

class _YourMoviesState extends State<YourMovies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Movies")),
      body: FirestoreListView(
        emptyBuilder: (context) => Center(
          child: Text(
            "No movies found",
            style: fontBody(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        query: videosCollection
            .where('creatorID', isEqualTo: widget.uid)
            .where("section", isEqualTo: "movies")
            .orderBy('title'),
        itemBuilder: (BuildContext context, DocumentSnapshot snapshot) {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  imageUrl: snapshot['banner'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  snapshot['title'],
                  style: fontBody(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  snapshot['genres'].join(", "),
                  style: fontBody(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  // Expanded(
                  //   child: TextButton(
                  //     onPressed: () {},
                  //     style: TextButton.styleFrom(backgroundColor: kStreamPrimaryColor, foregroundColor: kWhiteColor),
                  //     child: Text("Stats", style: fontButton(fontSize: 17.sp)),
                  //   ),
                  // ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.to(
                        () => EditMovie(videoID: snapshot.id, uid: widget.uid),
                        transition: Transition.cupertino,
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: kGreyColor2,
                        foregroundColor: kWhiteColor,
                      ),
                      child: Text("Edit", style: fontButton(fontSize: 17.sp)),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        snapshot.reference.update({
                          "active": !snapshot["active"],
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: kButtonColor,
                        foregroundColor: kWhiteColor,
                      ),
                      child: Text(
                        snapshot["active"] ? "Disable" : "Enable",
                        style: fontButton(fontSize: 17.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
