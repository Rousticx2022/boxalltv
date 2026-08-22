import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' as math;
import '../utils/styles.dart';

const Color kWhiteColor = Color(0xffffffff);
const Color kBlackColor = Color(0xff000000);
const Color kPrimaryColor = Color(0xff9a3c9d);
const Color kButtonColor = Color(0xffde3b25);
const Color kGreyColor1 = Color(0xff6f6f6f);
const Color kGreyColor2 = Color(0xff21242D);
const Color kStreamPrimaryColor = Color(0xff912a93);
const Color kSocialPrimaryColor = Color(0xfff3aa43);
const Color kReelsPrimaryColor = Color(0xff32afdb);
const Color kMusicPrimaryColor = Color(0xff6bc142);

Widget customCircularProgress({
  required Color strokeColor,
  double strokeWidth = 1,
}) => Center(
  child: CircularProgressIndicator.adaptive(
    strokeWidth: strokeWidth,
    valueColor: AlwaysStoppedAnimation<Color>(strokeColor),
  ),
);

void customSnackBar({required String text}) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey.shade900,
    textColor: kWhiteColor,
    fontSize: 18.0,
  );
}

Widget progressIndicator({String loadingText = ""}) => Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      customCircularProgress(strokeColor: kWhiteColor),
      if (loadingText.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(loadingText, style: const TextStyle(color: kWhiteColor)),
      ],
    ],
  ),
);

AnimatedBuilder rotateLogo(AnimationController controller, Widget child) =>
    AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: controller.value * 1.5 * math.pi,
          child: child,
        );
      },
      child: child,
    );

Widget qualityIcon(String name) {
  return Container(
    height: 30,
    margin: const EdgeInsets.only(right: 5),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      name.toUpperCase(),
      style: customTextStyleBody(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );
}

Widget qualityIconTV(String name) {
  return Container(
    height: 30,
    margin: const EdgeInsets.only(bottom: 5),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      name.toUpperCase(),
      style: customTextStyleBody(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );
}
