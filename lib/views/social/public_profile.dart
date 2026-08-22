import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:get/get.dart';
import 'package:numeral/numeral.dart';
import '../../controllers/public_profile_controller.dart';
import '../../utils/collections.dart';
import '../../utils/models.dart';
import '../../widgets/post_container.dart';
import '../edit_user_profile.dart';

class PublicProfile extends GetView<PublicProfileController> {
  const PublicProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Obx(
        () => controller.userData.isEmpty
            ? customCircularProgress(strokeColor: kSocialPrimaryColor)
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: context.width,
                    pinned: true,
                    floating: false,
                    backgroundColor: kBlackColor,
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: kBlackColor.withValues(alpha: 0.2),
                            ),
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      centerTitle: true,
                      background: Stack(
                        alignment: AlignmentDirectional.center,
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: controller.userData["thumbnail"],
                            placeholder: (c, s) =>
                                const ColoredBox(color: kGreyColor2),
                            errorWidget: (c, s, o) =>
                                const ColoredBox(color: kGreyColor2),
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: context.width,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, kBlackColor],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 70,
                            child: Column(
                              children: [
                                Hero(
                                  tag: controller.userID!,
                                  child: Container(
                                    height: context.width / 3,
                                    width: context.width / 3,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: kBlackColor,
                                      border: Border.all(
                                        color: kGreyColor2,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            controller.userData["profileImage"],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${Numeral(controller.userData["followers"]).format(fractionDigits: 2)} ${controller.userData["followers"] > 1 ? "Followers" : "Follower"}",
                                  style: fontBody(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        controller.userData["name"],
                        style: fontHeading(
                          color: kWhiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: kBlackColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () =>
                                  controller.toggleFollowingStatus(),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                backgroundColor: kButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                controller.isFollowing.value
                                    ? "Unfollow"
                                    : "Follow",
                                style: fontButton(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: kWhiteColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (controller.userID == controller.uid)
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () => Get.to(
                                  () => EditUserProfile(uid: controller.uid),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  backgroundColor: kGreyColor2,
                                  foregroundColor: kSocialPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Edit Profile",
                                  style: fontButton(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: kSocialPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                          if (controller.userID != controller.uid)
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () => {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  backgroundColor: kGreyColor2,
                                  foregroundColor: kSocialPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Add Friend",
                                  style: fontButton(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: kSocialPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FirestoreListView(
                      // padding: const EdgeInsets.all(20),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      pageSize: 10,
                      query: postsCollection
                          .where("active", isEqualTo: true)
                          .where("uid", isEqualTo: controller.userID!)
                          .orderBy('postDate', descending: true),
                      itemBuilder: (context, snapshot) {
                        Posts posts = Posts.fromDocument(snapshot);

                        return PostContainer(
                          posts: posts,
                          uid: controller.uid,
                          routeToProfile: false,
                          confirmDelete: controller.confirmDelete,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
