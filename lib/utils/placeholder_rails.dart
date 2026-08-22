import 'package:flutter/material.dart';

class PlaceholderRails {
  static PlaceholderRails instance = PlaceholderRails();
  Widget buildBannerPlaceholder(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(),
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemCount: 5,
      ),
    );
  }

  Widget buildPortraitPlaceholder(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(),
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemCount: 5,
      ),
    );
  }

  Widget buildCastPlaceholder(BuildContext context, {double size = 105}) {
    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(
          height: size,
          width: size,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: Colors.grey.shade900.withValues(alpha: 0.7),
          ),
        ),
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemCount: 5,
      ),
    );
  }

  Widget buildCrewPlaceholder(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(
          height: 50,
          width: 170,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: Colors.grey.shade900.withValues(alpha: 0.7),
          ),
        ),
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemCount: 5,
      ),
    );
  }
}
