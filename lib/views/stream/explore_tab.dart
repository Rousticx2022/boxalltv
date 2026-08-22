/*
Company: Shader Bytes
Developed By: Pradeepta Bhattacharya
*/

import 'package:auto_size_text/auto_size_text.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../../utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../utils/container_builder.dart';
import '../../utils/collections.dart';

class ExploreTab extends StatefulWidget {
  final String uid;
  const ExploreTab({super.key, required this.uid});
  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  TextEditingController searchController = TextEditingController();
  late Size size;
  String searchInput = "";
  bool doSearch = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBlackColor,
          automaticallyImplyLeading: false,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: kBlackColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
            ),
            child: TextFormField(
              controller: searchController,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                if (value == "") {
                  setState(() {
                    doSearch = false;
                  });
                } else {
                  setState(() {
                    doSearch = true;
                    searchInput = value.toLowerCase();
                  });
                }
              },
              style: customTextStyleBody(fontSize: 15.sp),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: customTextStyleBody(fontSize: 15.sp),
                hintText: "Search Movies, Series...",
                prefixIcon: doSearch
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          setState(() {
                            doSearch = false;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                      )
                    : Icon(
                        Remix.search_2_line,
                        color: Theme.of(context).iconTheme.color,
                      ),
              ),
            ),
          ),
          bottom: TabBar(
            labelColor: kWhiteColor,
            unselectedLabelColor: Colors.grey.shade400,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: kPrimaryColor,
            labelStyle: customTextStyleBody(fontSize: 15.sp),
            isScrollable: true,
            tabs: const [
              Tab(text: "Movies"),
              Tab(text: "Series"),
              Tab(text: "Genres"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: doSearch
                  ? videosCollection
                        .where("active", isEqualTo: true)
                        .where("section", isEqualTo: "movies")
                        .where("titleSearch", arrayContains: searchInput)
                        .snapshots()
                  : videosCollection
                        .where("active", isEqualTo: true)
                        .where("section", isEqualTo: "movies")
                        .snapshots(),
              builder: (context, fSnapshot) {
                if (!fSnapshot.hasData) {
                  return Center(
                    child: customCircularProgress(
                      strokeColor: Theme.of(context).primaryColor,
                    ),
                  );
                }
                List<DocumentSnapshot> filmList = fSnapshot.data!.docs;
                if (fSnapshot.hasData && filmList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/nothing.png",
                          width: size.width / 2,
                        ),
                        Text("Nothing here", style: customTextStyleBody()),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(5.0),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 14.h,
                    childAspectRatio: (14.h / (13.h * 3 / 2)),
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: filmList.length,
                  itemBuilder: (context, index) {
                    return ContainerBuilder(
                      uid: widget.uid,
                    ).videoGridContainer(context, filmList[index]);
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: doSearch
                  ? videosCollection
                        .where("active", isEqualTo: true)
                        .where("section", isEqualTo: "series")
                        .where("titleSearch", arrayContains: searchInput)
                        .snapshots()
                  : videosCollection
                        .where("active", isEqualTo: true)
                        .where("section", isEqualTo: "series")
                        .snapshots(),
              builder: (context, wSnapshot) {
                if (!wSnapshot.hasData) {
                  return Center(
                    child: customCircularProgress(
                      strokeColor: Theme.of(context).primaryColor,
                    ),
                  );
                }
                List<DocumentSnapshot> webList = wSnapshot.data!.docs;
                if (wSnapshot.hasData && webList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/nothing.png",
                          width: size.width / 2,
                        ),
                        Text("Nothing here", style: customTextStyleBody()),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(5.0),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 14.h,
                    childAspectRatio: (14.h / (13.h * 3 / 2)),
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: webList.length,
                  itemBuilder: (context, index) {
                    return ContainerBuilder(
                      uid: widget.uid,
                    ).videoGridContainer(context, webList[index]);
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: genresCollection
                  .where("active", isEqualTo: true)
                  .orderBy("name")
                  .snapshots(),
              builder: (context, gSnapshot) {
                if (!gSnapshot.hasData) {
                  return Center(
                    child: customCircularProgress(
                      strokeColor: Theme.of(context).primaryColor,
                    ),
                  );
                }
                List<DocumentSnapshot> genresList = gSnapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.all(5.0),
                  itemCount: genresList.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        "/genre_videos/${genresList[index]["name"]}",
                        parameters: {
                          "genreID": genresList[index].id,
                          "uid": widget.uid,
                        },
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xff192231),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // CachedNetworkImage(
                            //     imageUrl: genresList[index]["icon"], placeholder: (context, d) => Container(), width: 50, height: 50),
                            AutoSizeText(
                              genresList[index]["name"],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: customTextStyleBody(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
