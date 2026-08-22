library;

import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'smart_image.dart';

import 'multiple_image_view.dart';

class NewsfeedMultipleImageView extends StatelessWidget {
  final List imageUrls;
  final double marginLeft;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final String fileSourceType;

  const NewsfeedMultipleImageView({
    super.key,
    this.marginLeft = 0,
    this.marginTop = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    required this.imageUrls,
    this.fileSourceType = "network",
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, costraints) => Container(
        width: costraints.maxWidth,
        height: costraints.maxWidth,
        margin: EdgeInsets.fromLTRB(
          marginLeft,
          marginTop,
          marginRight,
          marginBottom,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGreyColor1, width: 0.3),
        ),
        child: GestureDetector(
          child: MultipleImageView(
            imageUrls: imageUrls,
            fileSourceType: fileSourceType,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(imageUrls: imageUrls),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final List imageUrls;
  const ImageViewer({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Container(
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
                Expanded(
                  child: ImageSlideshow(
                    initialPage: 0,
                    indicatorColor: Colors.red,
                    indicatorBackgroundColor: Colors.grey,
                    isLoop: imageUrls.length > 1,
                    children: imageUrls
                        .map(
                          (e) => ClipRect(
                            child: e["type"] == "video"
                                ? SmartVideo(src: e["url"], isPost: true)
                                : SmartImage(
                                    e["url"],
                                    fit: BoxFit.contain,
                                    isPost: true,
                                  ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
