import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/container_builder.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../utils/collections.dart';

class FavouriteTab extends StatefulWidget {
  final String uid;
  const FavouriteTab({super.key, required this.uid});

  @override
  State<FavouriteTab> createState() => _FavouriteTabState();
}

class _FavouriteTabState extends State<FavouriteTab> {
  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: usersCollection
          .doc(widget.uid)
          .collection("watchlist")
          .orderBy("addedAt", descending: true),
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

                  if (vSnapshot.hasData && !vDetails.exists) {
                    return const SizedBox();
                  }

                  if (vSnapshot.hasData && !vDetails["active"]) {
                    fav.reference.delete();
                  }

                  return ContainerBuilder(uid: widget.uid)
                      .videoGridContainer(context, vDetails);
                });
          },
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 14.h,
            childAspectRatio: (14.h / (13.h * 3 / 2)),
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
        );
      },
    );
  }
}
