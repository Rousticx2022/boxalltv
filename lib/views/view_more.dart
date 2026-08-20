import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../controllers/view_more_controller.dart';
import '../utils/container_builder.dart';

class ViewMore extends GetView<ViewMoreController> {
  const ViewMore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(controller.section!),
      ),
      body: FirestoreQueryBuilder(
          query: controller.query!,
          builder: (context, snapshot, _) {
            return GridView.builder(
                itemCount: snapshot.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.width ~/ 120,
                    childAspectRatio: (120 / 180),
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5),
                itemBuilder: (context, index) {
                  if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                    snapshot.fetchMore();
                  }
                  final user = snapshot.docs[index].data();

                  return Center(
                      child: ContainerBuilder(uid: controller.uid!)
                          .videoGridContainer(context, snapshot.docs[index]));
                });
          }),
    );
  }
}
