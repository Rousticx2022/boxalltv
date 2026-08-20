import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:get/get.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/collections.dart';
import 'package:http/http.dart' as http;

class NotificationsController extends GetxController {
  String? uid = Get.parameters["uid"];

  Future<void> acceptFriendRequest(String friendID, String notificationID) async {
    customSnackBar(text: "You are now friends");

    await usersCollection
        .doc(uid)
        .collection("friends")
        .doc(friendID)
        .update({"status": "friends"});
    await usersCollection
        .doc(friendID)
        .collection("friends")
        .doc(uid)
        .update({"status": "friends"});
    await usersCollection
        .doc(uid!)
        .collection("notifications")
        .doc(notificationID)
        .delete();
    await usersCollection.doc(uid).collection("notifications").add({
      "purpose": "and you are now friends",
      "sentAt": DateTime.now(),
      "type": "now_friends",
      "unread": true,
      "sentBy": friendID,
    });
    await usersCollection.doc(friendID).collection("notifications").add({
      "purpose": "Accepted your friend request",
      "sentAt": DateTime.now(),
      "type": "friend_request_accept",
      "unread": true,
      "sentBy": uid,
    });

    BottomTabController bottomTabController = Get.find();

    http.Response response = await http.post(
      Uri.parse("http://65.109.39.177:7110/send_notification"),
      body: jsonEncode({
        "title": "Friend request accepted",
        "message":
            "${bottomTabController.userData["name"]} accepted your friend request",
        "uid": friendID,
      }),
    );
  }

  Future<void> rejectFriendRequest(String friendID, String notificationID) async {
    customSnackBar(text: "Friend request rejected");
    await usersCollection
        .doc(uid!)
        .collection("notifications")
        .doc(notificationID)
        .delete();
    await usersCollection
        .doc(uid!)
        .collection("friends")
        .doc(friendID)
        .delete();
    await usersCollection
        .doc(friendID)
        .collection("friends")
        .doc(uid!)
        .delete();
    http.Response response = await http.post(
      Uri.parse("http://65.109.39.177:7110/send_notification"),
      body: jsonEncode({
        "title": "Friend request rejected",
        "message":
            "${Get.find<BottomTabController>().userData["name"]} rejected your friend request",
        "uid": friendID,
      }),
    );
  }

  @override
  void onReady() async {
    await usersCollection
        .doc(uid)
        .collection("notifications")
        .where("unread", isEqualTo: true)
        .get()
        .then((value) async {
      for (DocumentSnapshot doc in value.docs) {
        doc.reference.update({"unread": false});
      }
    });
    super.onReady();
  }
}
