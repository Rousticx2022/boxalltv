part of 'menu.dart';

extension _MenuStateExt3 on _MenuState {
  Widget buildMain(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff000000), Color(0xff203A43), Color(0xff000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GetX<BottomTabController>(builder: (btController) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: kWhiteColor),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            const url = 'https://frametv.tv/#/support';
                            await launchUrl(Uri.parse(url));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Remix.question_fill,
                                color: kWhiteColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: AvatarGlow(
                      repeat: true,
                      glowRadiusFactor: 0.5,
                      glowColor: Theme.of(context).primaryColor,
                      child: Material(
                        elevation: 8.0,
                        shape: const CircleBorder(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: btController.userData["profileImage"],
                            placeholder: (context, s) =>
                                ColoredBox(color: kWhiteColor.withValues(alpha: 0.1)),
                            height: 25.w,
                            width: 25.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () =>
                              Get.to(() => EditUserProfile(uid: widget.uid)),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5,
                            children: [
                              Text(
                                btController.userData["name"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: fontPoppins(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w400),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                decoration: ShapeDecoration(
                                  shape: const CircleBorder(),
                                  color: kWhiteColor.withValues(alpha: 0.1),
                                ),
                                child: const Icon(Remix.pencil_fill,
                                    size: 18, color: kWhiteColor),
                              ),
                            ],
                          ),
                        ),
                        if (btController.userData["subscribed"])
                          Text(
                            "Subscription valid till: ${DateFormat.yMEd().format(btController.userData["subscriptionDuration"].toDate())}",
                            style: fontPoppins(
                                color: kWhiteColor.withValues(alpha: 0.7)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ListTile(
                          onTap: () => Get.toNamed("/wallet"),
                          minLeadingWidth: 0,
                          leading: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Remix.wallet_fill,
                                color: kWhiteColor),
                          ),
                          title: Text("Your Wallet",
                              style: fontPoppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400)),
                          trailing: RichText(
                            text: TextSpan(
                              text:
                                  "${btController.userData["wallet"].toStringAsFixed(2)}",
                              style: fontBody(
                                  fontSize: 18.sp,
                                  color: kWhiteColor,
                                  fontWeight: FontWeight.w400),
                              children: [
                                TextSpan(
                                  text: " coins",
                                  style: fontBody(
                                      fontSize: 14.sp,
                                      color: kWhiteColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                            color: kWhiteColor.withValues(alpha: 0.2),
                            indent: 20,
                            endIndent: 20),
                        ListTile(
                          onTap: () =>
                              Get.to(() => Subscriptions(uid: widget.uid)),
                          minLeadingWidth: 0,
                          leading: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Remix.secure_payment_fill,
                                color: kWhiteColor),
                          ),
                          title: Text("Subscriptions",
                              style: fontPoppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400)),
                          trailing: btController.userData["subscribed"]
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7.0, vertical: 7),
                                      decoration: const ShapeDecoration(
                                        shape: StadiumBorder(),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xffdb3445),
                                            Color(0xfff71735)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Active",
                                        style: fontPoppins(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: kWhiteColor),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        Divider(
                            color: kWhiteColor.withValues(alpha: 0.2),
                            indent: 20,
                            endIndent: 20),
                        ListTile(
                          onTap: () {
                            Get.find<AdsService>().showRewardedAd(1);
                            Get.to(() => SavedVideos(uid: widget.uid));
                          },
                          minLeadingWidth: 0,
                          leading: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Remix.save_2_fill,
                                color: kWhiteColor),
                          ),
                          title: Text("Saved videos",
                              style: fontPoppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400)),
                        ),
                        Divider(
                            color: kWhiteColor.withValues(alpha: 0.2),
                            indent: 20,
                            endIndent: 20),
                        ListTile(
                          onTap: () =>
                              Get.to(() => TrackOrders(uid: widget.uid)),
                          minLeadingWidth: 0,
                          leading: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Remix.truck_fill,
                                color: kWhiteColor),
                          ),
                          title: Text("Track Orders",
                              style: fontPoppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400)),
                        ),
                        Divider(
                            color: kWhiteColor.withValues(alpha: 0.2),
                            indent: 20,
                            endIndent: 20),
                        ListTile(
                          onTap: () async {
                            Get.find<AdsService>().showRewardedAd(1);
                            setState(() {
                              channelLoading = true;
                            });
                            DocumentSnapshot doc = await creatorsCollection
                                .doc(btController.uid!)
                                .get();
                            setState(() {
                              channelLoading = false;
                            });
                            if (doc.exists) {
                              if (doc["active"] && doc["activated"]) {
                                Get.toNamed("/your_channel",
                                    parameters: {"uid": btController.uid!});
                                return;
                              }
                              if (!doc["active"] && doc["activated"]) {
                                showCreatorAccountBlocked();
                                return;
                              }
                              showCreatorAccountPending();
                              return;
                            }
                            Get.to(() => BecomeACreator(uid: widget.uid));
                          },
                          minLeadingWidth: 0,
                          leading: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Remix.vidicon_2_fill,
                                color: kWhiteColor),
                          ),
                          title: Text("Media Library",
                              style: fontPoppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400)),
                          trailing: channelLoading
                              ? const CupertinoActivityIndicator()
                              : null,
                        ),
                        Divider(
                            color: kWhiteColor.withValues(alpha: 0.2),
                            indent: 20,
                            endIndent: 20),
                        ListTile(
                          onTap: () async {
                            Get.find<AdsService>().showRewardedAd(1);
                            setState(() {
                              advertisersLoading = true;
                            });
                            DocumentSnapshot doc = await advertisersCollection
                                .doc(btController.uid!)
                                .get();
                            setState(() {
                              advertisersLoading = false;
                            });
                            if (doc.exists) {
                              if (doc["active"] && doc["activated"]) {
                                Get.toNamed("/advertiser");
                                return;
                              }
                              if (!doc["active"] && doc["activated"]) {
                                showAdvertiserAccountBlocked();
                                return;
                              }
                              showAdvertiserAccountPending();
                              return;
                            }
                            Get.to(() => BecomeAnAdvertiser(uid: widget.uid));
                          },
                          minLeadingWidth: 0,
                          leading: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Remix.advertisement_fill,
                                color: kWhiteColor),
                          ),
                          title: Text("Advertisers",
                              style: fontPoppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400)),
                          trailing: advertisersLoading
                              ? const CupertinoActivityIndicator()
                              : null,
                        ),
                        Divider(
                            color: kWhiteColor.withValues(alpha: 0.2),
                            indent: 20,
                            endIndent: 20),
                        ListTile(
                          onTap: () async {
                            const url =
                                'mailto:<contact@frametv.tv>?subject=<Mention a subject please>&body=<Describe your problem in brief!>';
                            await launchUrl(Uri.parse(url));
                          },
                          minLeadingWidth: 0,
                          leading: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child:
                                const Icon(Remix.mail_fill, color: kWhiteColor),
                          ),
                          title: Text("Contact Us",
                              style: fontPoppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400)),
                        ),
                        Divider(
                            color: kWhiteColor.withValues(alpha: 0.2),
                            indent: 20,
                            endIndent: 20),
                        ListTile(
                          onTap: () {
                            UserService.instance
                                .toggleActiveStatus(widget.uid, false);
                            UserService.instance.signOut();
                          },
                          minLeadingWidth: 0,
                          leading: Container(
                            padding: const EdgeInsets.all(7.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kWhiteColor.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Remix.logout_circle_r_line,
                                color: kWhiteColor),
                          ),
                          title: Text("Logout",
                              style: fontPoppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
