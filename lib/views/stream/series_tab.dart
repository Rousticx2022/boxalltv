import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/container_builder.dart';
import '../../utils/styles.dart';
import '../../utils/collections.dart';

class SeriesTab extends StatefulWidget {
  final String uid;
  const SeriesTab({super.key, required this.uid});

  @override
  State<SeriesTab> createState() => _SeriesTabState();
}

class _SeriesTabState extends State<SeriesTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: videosCollection
            .where("active", isEqualTo: true)
            .where("section", isEqualTo: "series")
            .snapshots(),
        builder: (context, fSnapshot) {
          if (!fSnapshot.hasData) {
            return Center(
                child: customCircularProgress(strokeColor: kPrimaryColor));
          }
          List<DocumentSnapshot> filmList = fSnapshot.data!.docs;
          if (fSnapshot.hasData && filmList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/nothing.png", width: context.width / 2),
                  Text("Nothing here", style: customTextStyleBody()),
                ],
              ),
            );
          }
          return GridView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 14.h,
                  childAspectRatio: (14.h / (13.h * 3 / 2)),
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5),
              itemCount: filmList.length,
              itemBuilder: (context, index) {
                return ContainerBuilder(uid: widget.uid)
                    .videoGridContainer(context, filmList[index]);
              });
        });
  }
}
