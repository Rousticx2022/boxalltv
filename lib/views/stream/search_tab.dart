import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:boxalltv/widgets/watch_button.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import '../../utils/collections.dart';
import '../../utils/container_builder.dart';

class SearchTab extends StatefulWidget {
  final String uid;
  const SearchTab({super.key, required this.uid});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  TextEditingController searchController = TextEditingController();
  List filmList = [], subtitlesList = [];
  bool doSearch = false;
  RxString searchText = "".obs;

  Future<void> getSearchResult() async {
    if (searchText.isEmpty) {
      setState(() {
        filmList.clear();
        subtitlesList.clear();
      });
      return;
    }
    http.Response response = await http.get(
      Uri.parse("http://45.56.74.123:7110/search?q=${searchText.value}"),
    );
    if (response.statusCode == 200) {
      filmList = jsonDecode(response.body);
      setState(() {});
    }
    http.Response response2 = await http.get(
      Uri.parse(
        "http://45.56.74.123:7110/search_subtitle?q=${searchText.value}",
      ),
    );
    if (response2.statusCode == 200) {
      subtitlesList = jsonDecode(response2.body);
      setState(() {});
    }
  }

  @override
  void initState() {
    debounce(searchText, (callback) => getSearchResult());
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: TextFormField(
            controller: searchController,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              doSearch = value.isNotEmpty;
              searchText.value = value;
              setState(() {});
            },
            style: fontBody(fontSize: 15.sp),
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              fillColor: Colors.grey.shade900,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
              hintStyle: fontBody(fontSize: 15.sp),
              hintText: "Search Movies, Series...",
              prefixIcon: Icon(
                Remix.search_2_line,
                color: kWhiteColor,
                size: 18.sp,
              ),
              suffixIcon: doSearch
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        setState(() {
                          searchText.value = "";
                          doSearch = false;
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              if (filmList.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  height: 20.h,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: filmList.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: videosCollection
                            .doc(filmList[index]["tag"])
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          DocumentSnapshot vdata = snapshot.data!;
                          if (snapshot.hasData && !vdata.exists) {
                            return const SizedBox();
                          }
                          return ContainerBuilder(
                            uid: widget.uid,
                          ).videoContainerPortrait(context, vdata);
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 10);
                    },
                  ),
                ),
              if (subtitlesList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Text(
                    "Matching subtitles...",
                    style: fontHeading(
                      fontSize: 20.sp,
                      color: kStreamPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                itemCount: subtitlesList.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: videosCollection
                        .doc(subtitlesList[index]["info"]["vid"])
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      DocumentSnapshot vdata = snapshot.data!;
                      if (snapshot.hasData && !vdata.exists) {
                        return const SizedBox();
                      }
                      return Container(
                        height: 13.h * 3 / 2 + 20,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kGreyColor2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: vdata["poster"],
                                height: 13.h * 3 / 2,
                                width: 13.h,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subtitlesList[index]["subtitle"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: fontBody(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      color: kWhiteColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Play time",
                                    style: fontBody(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: kWhiteColor.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text:
                                          "${subtitlesList[index]["info"]["start"]}",
                                      style: fontBody(),
                                      children: [
                                        const TextSpan(text: " -> "),
                                        TextSpan(
                                          text:
                                              "${subtitlesList[index]["info"]["end"]}",
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: WatchSearchButton(
                                      startTime:
                                          subtitlesList[index]["info"]["start"],
                                      uid: widget.uid,
                                      vid: vdata.id,
                                      pricing: vdata["pricing"],
                                      title: vdata["title"],
                                      type: vdata["type"],
                                      section: vdata["section"],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (c, i) => const SizedBox(height: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
