import 'package:flutter/material.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:get/get.dart';

import '../../utils/rails_builder.dart';

class AllTab extends StatefulWidget {
  final String uid;
  const AllTab({super.key, required this.uid});

  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: RailsBuilder(uid: widget.uid).buildCarousel(),
        ),
        RailsBuilder(uid: widget.uid).buildContinueWatching(),
        GetX<BottomTabController>(builder: (btc) {
          return btc.userData.isEmpty
              ? const SizedBox()
              : RailsBuilder(uid: widget.uid)
                  .buildRecommended(btc.userData["recommendations"]);
        }),
        RailsBuilder(uid: widget.uid).buildRent(),
        RailsBuilder(uid: widget.uid).buildTrending(),
        RailsBuilder(uid: widget.uid).buildPopularGenres(),
        RailsBuilder(uid: widget.uid).buildMostPopular(),
        RailsBuilder(uid: widget.uid).buildMostViewed(),
        const SizedBox(height: 50),
      ],
    );
  }
}
