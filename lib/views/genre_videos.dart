import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../controllers/genre_videos_controller.dart';
import '../utils/container_builder.dart';
import '../utils/collections.dart';

class GenreVideos extends GetView<GenreVideosController> {
  const GenreVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.genre!),
      ),
      body: SafeArea(
        child: FirestoreQueryBuilder(
          query: videosCollection
              .where("active", isEqualTo: true)
              .where('genres', arrayContains: controller.genre!)
              .orderBy("title"),
          builder: (context, snapshot, _) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                  snapshot.fetchMore();
                }

                final fav = snapshot.docs[index];

                return StreamBuilder<DocumentSnapshot>(
                    stream: videosCollection.doc(fav.id).snapshots(),
                    builder: (context, vSnapshot) {
                      if (!vSnapshot.hasData) {
                        return Container(
                          height: 180,
                          width: 120,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12)),
                        );
                      }
                      DocumentSnapshot vDetails = vSnapshot.data!;
                      return ContainerBuilder(uid: controller.uid!)
                          .videoGridContainer(context, vDetails);
                    });
              },
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: context.width / 2 - 30,
                  mainAxisExtent: (context.width / 2 - 30) * 3 / 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20),
            );
          },
        ),
      ),
    );
  }
}
