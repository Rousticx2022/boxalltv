import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:numeral/numeral.dart';
import 'package:remixicon/remixicon.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';

class LikeButton extends StatefulWidget {
  final String uid, postOwner, postID;
  const LikeButton({
    super.key,
    required this.uid,
    required this.postID,
    required this.postOwner,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  void toggleLikes({
    required String uid,
    required String postID,
    required bool liked,
  }) async {
    if (liked) {
      await postDataCollection.doc(postID).update({
        "likes": FieldValue.arrayRemove([uid]),
      });
      await postsCollection.doc(postID).update({
        "likes": FieldValue.increment(-1),
      });
    } else {
      await postDataCollection.doc(postID).update({
        "likes": FieldValue.arrayUnion([uid]),
      });
      await postsCollection.doc(postID).update({
        "likes": FieldValue.increment(1),
      });

      // if (uid != widget.postOwner) {
      //   await sendNotification
      //       .call(<String, dynamic>{'uid': uid, 'fid': widget.postOwner, "type": "post", "id": postID, "purpose": "Liked your post"});
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: postDataCollection.doc(widget.postID).snapshots(),
      builder: (context, snapshot) {
        bool liked = false;
        int likes = 0;
        if (!snapshot.hasData) {
          liked = false;
          likes = 0;
        }

        if (snapshot.hasData) {
          likes = snapshot.data!["likes"].length;
        }

        if (snapshot.hasData && snapshot.data!["likes"].contains(widget.uid)) {
          liked = true;
        }

        return TextButton.icon(
          onPressed: () {
            toggleLikes(uid: widget.uid, postID: widget.postID, liked: liked);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white10,
            foregroundColor: kSocialPrimaryColor,
            shape: const StadiumBorder(),
          ),
          label: Text(
            Numeral(likes).format(fractionDigits: 2),
            style: customTextStyleBody(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          icon: Icon(
            liked ? Remix.thumb_up_fill : Remix.thumb_up_line,
            size: 20,
            color: liked ? kSocialPrimaryColor : kWhiteColor,
          ),
        );
      },
    );
  }
}
