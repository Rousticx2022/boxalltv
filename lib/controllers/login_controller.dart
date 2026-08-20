import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../views/maintenance.dart';

class LoginController extends GetxController with WidgetsBindingObserver {
  var passwordVisible = false.obs, loading = false.obs;
  bool isAndroid = Platform.isAndroid;
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  final emailFocus = FocusNode(),
      passwordFocus = FocusNode(),
      signButtonFocus = FocusNode();

  void togglePassword() {
    passwordVisible.value = !passwordVisible.value;
  }

  void emailPasswordLogin() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    loading.value = true;
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .then((currentUser) async {
          DocumentSnapshot generalDoc =
              await generalCollection.doc("RCVdTHFlVIVCUjuiD1pm").get();

          customSnackBar(text: "Login successful");

          if (!generalDoc["isLive"] || !generalDoc["isUnderMaintenance"]) {
            Get.offAll(() => Maintenance(
                isLive: generalDoc["isLive"],
                isUnderMaintenance: generalDoc["isUnderMaintenance"]));
            return;
          }

          Get.offAllNamed("/bottom_tab",
              parameters: {"uid": currentUser.user!.uid});
        });
      } on FirebaseAuthException catch (e) {
        loading.value = false;

        if (e.code == 'user-not-found') {
          customSnackBar(text: "Account not found");
        } else if (e.code == 'wrong-password') {
          customSnackBar(text: "Wrong Password");
        } else if (e.code == 'user-disabled') {
          customSnackBar(text: "Your account is deactivated");
        }
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    signButtonFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
