import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:remixicon/remixicon.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/bottomtab_controller.dart';
import '../../services/music_serivce.dart';
import '../menu.dart';

class MusicsTab extends StatefulWidget {
  final String uid;
  const MusicsTab({super.key, required this.uid});

  @override
  State<MusicsTab> createState() => _MusicsTabState();
}

class _MusicsTabState extends State<MusicsTab> {
  bool playing = false;
  Map musicData = {};
  String playingID = "";
  int currentIndex = 0, position = 0;
  MusicService musicService = Get.find<MusicService>();

  Future<void> playMusic({required String id, required Map data}) async {
    musicService.playAudio(url: data["url"]);
    if (!mounted) return;
    setState(() {
      playingID = id;
      musicData = data;
      playing = true;
    });
    if (playing) {
      musicService.audioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          if (!mounted) return;
          setState(() {
            playing = false;
          });
        }
      });
    }
  }

  Future<void> pauseMusic() async {
    musicService.pauseAudio();
    if (!mounted) return;
    setState(() {
      playing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMusicPrimaryColor,
        title: GestureDetector(
          onTap: () =>
              Get.offAllNamed("/bottom_tab", parameters: {"uid": widget.uid}),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kBlackColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset("assets/logo.png", height: kToolbarHeight - 16),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.toNamed("/cart", parameters: {"uid": widget.uid}),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kBlackColor,
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: GetX<BottomTabController>(builder: (btController) {
                return btController.unreadNotifications.value == 0
                    ? const Icon(Icons.shopping_cart_outlined)
                    : badges.Badge(
                        position:
                            badges.BadgePosition.topEnd(top: -10, end: -4),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: kMusicPrimaryColor,
                          padding: const EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(20),
                          elevation: 0,
                        ),
                        badgeContent: Text(btController.cartItems.toString(),
                            style: fontButton(fontSize: 12)),
                        child: const Icon(Icons.shopping_cart_outlined),
                      );
              }),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Get.toNamed("/notifications", parameters: {"uid": widget.uid}),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kBlackColor,
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: GetX<BottomTabController>(builder: (btController) {
                return btController.unreadNotifications.value == 0
                    ? const Icon(Remix.notification_2_line)
                    : badges.Badge(
                        position:
                            badges.BadgePosition.topEnd(top: -10, end: -4),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: kStreamPrimaryColor,
                          padding: const EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(20),
                          elevation: 0,
                        ),
                        badgeContent: Text(
                            btController.unreadNotifications.toString(),
                            style: fontButton(fontSize: 12)),
                        child: const Icon(Remix.notification_2_line),
                      );
              }),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kBlackColor,
            ),
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () => Get.to(() => Menu(uid: widget.uid),
                    transition: Transition.cupertino),
                icon: const Icon(Remix.menu_3_line),
                color: kWhiteColor),
          ),
        ],
      ),
      body: const Center(
        child: Text("Coming soon"),
      ),
    );
  }
}
