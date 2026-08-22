import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/exceptions.dart';

class BankDetailsController extends GetxController {
  final String uid;
  BankDetailsController({required this.uid});

  final formKey = GlobalKey<FormState>();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController swiftCodeController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBankData();
  }

  @override
  void onClose() {
    bankNameController.dispose();
    swiftCodeController.dispose();
    accountNameController.dispose();
    branchNameController.dispose();
    accountNumberController.dispose();
    super.onClose();
  }

  Future<void> fetchBankData() async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey("bankDetails")) {
          final bankDetails = data["bankDetails"];
          if (bankDetails != null &&
              bankDetails is Map &&
              bankDetails.isNotEmpty) {
            accountNameController.text = bankDetails["accountName"] ?? '';
            accountNumberController.text = bankDetails["accountNumber"] ?? '';
            bankNameController.text = bankDetails["bankName"] ?? '';
            branchNameController.text = bankDetails["branch"] ?? '';
            swiftCodeController.text = bankDetails["swiftCode"] ?? '';
          }
        }
      }
    } catch (e) {
      throw AppException("Failed to fetch bank data", originalException: e);
    }
  }

  Future<void> updateBankDetails() async {
    if (!formKey.currentState!.validate()) return;

    Get.dialog(progressIndicator(), barrierDismissible: false);
    try {
      await usersCollection.doc(uid).update({
        "bankDetails": {
          "accountName": accountNameController.text,
          "accountNumber": accountNumberController.text,
          "bankName": bankNameController.text,
          "branch": branchNameController.text,
          "swiftCode": swiftCodeController.text,
        },
      });
      Get.back(); // close dialog
      Get.back(); // close bottom sheet
      customSnackBar(text: "Bank details updated");
    } catch (e) {
      Get.back(); // close dialog
      customSnackBar(text: "Failed to update bank details");
      throw AppException("Failed to update bank details", originalException: e);
    }
  }
}
