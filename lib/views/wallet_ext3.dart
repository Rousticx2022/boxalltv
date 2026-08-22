part of 'wallet.dart';

extension _WalletStateExt3 on _WalletState {
  Widget buildMain(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Your Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          GetX<BottomTabController>(
            builder: (btController) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: RichText(
                  text: TextSpan(
                    text:
                        "${btController.userData["wallet"].toStringAsFixed(2)}",
                    style: fontBody(
                      fontSize: 24.sp,
                      color: kWhiteColor,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: " coins",
                        style: fontBody(
                          fontSize: 18.sp,
                          color: kWhiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  "Wallet balance",
                  style: fontBody(
                    fontSize: 18.sp,
                    color: kWhiteColor.withValues(alpha: 0.7),
                  ),
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          openWithdrawSheet(btController);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: const ShapeDecoration(
                            shape: StadiumBorder(),
                            gradient: LinearGradient(
                              colors: [Color(0xffdb3445), Color(0xfff71735)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Withdraw",
                            style: fontBody(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: kWhiteColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Daily Check-in (Earn 1 coin)",
                  style: fontBody(fontSize: 16.sp, color: kWhiteColor),
                ),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    DateTime date = to7Days[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color:
                            checkInDates.contains(
                              DateFormat("dd-MM-yyyy").format(date),
                            )
                            ? const Color(0xffff0000)
                            : kWhiteColor.withValues(alpha: 0.1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            date.day.toString(),
                            style: fontBody(
                              fontSize: 16.sp,
                              color: kWhiteColor,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            getWeekdays(date.weekday).toUpperCase(),
                            style: fontBody(
                              fontSize: 12.sp,
                              color: kWhiteColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 15.0),
                GestureDetector(
                  onTap: () async {
                    if (checkInDates.contains(
                      DateFormat("dd-MM-yyyy").format(today),
                    )) {
                      customSnackBar(text: "You have already checked in today");
                      return;
                    }

                    Get.find<AdsService>().showRewardedAdEarn(1);
                    await usersCollection
                        .doc(uid)
                        .collection("checkIn")
                        .doc(DateFormat("dd-MM-yyyy").format(today))
                        .set({"date": today});

                    fetchCheckInDates();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xffdb3445), Color(0xfff71735)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Check-in",
                      style: fontBody(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30.0),
          Text(
            "More ways to earn",
            style: fontBody(fontSize: 16.sp, color: kWhiteColor),
          ),
          const SizedBox(height: 20.0),
          ListTile(
            onTap: () async {
              if (box.read("shareRewardEarned") ?? false) {
                customSnackBar(
                  text: "You have already earned the reward for sharing",
                );
                return;
              } else {
                box.write("shareRewardEarned", true);

                Get.find<AdsService>().showRewardedAdEarn(2, forSharing: true);
                setState(() {
                  rewardEarnedForSharing = true;
                });
              }
            },
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            tileColor: kWhiteColor.withValues(alpha: 0.1),
            leading: Container(
              padding: const EdgeInsets.all(7.0),
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: kWhiteColor.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.share, color: kWhiteColor),
            ),
            minLeadingWidth: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              "Share with a Friend",
              style: fontBody(
                fontSize: 16.sp,
                color: kWhiteColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            subtitle: Text(
              "Earn 2 coins",
              style: fontBody(
                fontSize: 13.sp,
                color: kWhiteColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 7,
                  ),
                  decoration: const ShapeDecoration(
                    shape: StadiumBorder(),
                    gradient: LinearGradient(
                      colors: [Color(0xffdb3445), Color(0xfff71735)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    rewardEarnedForSharing ? "Claimed" : "Earn",
                    style: fontBody(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: kWhiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          GetX<AdsService>(
            builder: (adsService) => ListTile(
              onTap: () {
                if (adsService.isRewardingTimer.value) {
                  customSnackBar(text: "Please wait for the timer to finish");
                  return;
                }
                Get.find<AdsService>().showRewardedAdEarn(1);
                Get.find<AdsService>().startEarnRewardTimer();
              },
              tileColor: kWhiteColor.withValues(alpha: 0.1),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
              leading: Container(
                padding: const EdgeInsets.all(7.0),
                decoration: ShapeDecoration(
                  shape: const CircleBorder(),
                  color: kWhiteColor.withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.play_arrow, color: kWhiteColor),
              ),
              minLeadingWidth: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                "Earn rewards",
                style: fontBody(
                  fontSize: 16.sp,
                  color: kWhiteColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                "Watch a video ad and earn 1 coin",
                style: fontBody(
                  fontSize: 13.sp,
                  color: kWhiteColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7.0,
                      vertical: 7,
                    ),
                    decoration: const ShapeDecoration(
                      shape: StadiumBorder(),
                      gradient: LinearGradient(
                        colors: [Color(0xffdb3445), Color(0xfff71735)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      adsService.isRewardingTimer.value
                          ? "${adsService.rewardTimer.value}s"
                          : "Watch",
                      style: fontBody(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
