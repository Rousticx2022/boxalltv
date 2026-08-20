import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../utils/collections.dart';

class PostDetailsController extends GetxController {
  String? postID = Get.parameters['postID'];
  String uid = FirebaseAuth.instance.currentUser!.uid;

  RxMap postData = {}.obs;

  FocusNode keyboardFocus = FocusNode();

  final TextEditingController commentController = TextEditingController();

  Stream<Map> fetchPostData() {
    Stream stream = postsCollection.doc(postID).snapshots();
    return stream.map((event) => event.data());
  }

  @override
  void onInit() {
    postData.bindStream(fetchPostData());
    super.onInit();
  }

  @override
  void onClose() {
    commentController.dispose();
    keyboardFocus.dispose();
    super.onClose();
  }
}
