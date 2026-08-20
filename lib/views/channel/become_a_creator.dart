import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:boxalltv/views/channel/creator_form.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BecomeACreator extends StatelessWidget {
  final String uid;
  const BecomeACreator({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kButtonColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.2, 1],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: kToolbarHeight + 20),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.w),
                child: Image.asset("assets/lions_share.jpg", width: 50.w),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20),
              child: Text(
                "Step into the future with Frame, where creators aren't just a part of the platform — they are the platform. In an era where content is king, we're revolutionizing the realm by flipping the script on traditional revenue models. Frame is where creativity meets prosperity, ensuring that those who light up our digital world with their artistry receive the lion's share of the profits. Say goodbye to meager percentages and hello to a roaring majority. With Frame, your passion is not just showcased; it's handsomely rewarded. Unleash your potential where every pixel of your creativity contributes to your prosperity. Welcome to Frame — where your talent isn't just seen, it's valued.",
                style: fontBody(fontSize: 15.sp),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.off(() => CreatorForm(uid: uid));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kWhiteColor,
                  foregroundColor: kBlackColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("Apply Now",
                    style: fontButton(
                        fontSize: 18.sp, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: kWhiteColor,
                ),
                child: Text("Terms & Conditions", style: fontButton()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
