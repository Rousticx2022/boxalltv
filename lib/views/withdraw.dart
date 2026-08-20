import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/controllers/bottomtab_controller.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/collections.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/styles.dart';

class Withdraw extends StatefulWidget {
  final double amount, minWithdraw, coinsValuation;
  const Withdraw(
      {super.key,
      required this.amount,
      required this.minWithdraw,
      required this.coinsValuation});

  @override
  State<Withdraw> createState() => _WithdrawState();
}

class _WithdrawState extends State<Withdraw> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController(),
      accountNumberController = TextEditingController(),
      accountNameController = TextEditingController(),
      branchController = TextEditingController(),
      swiftCodeController = TextEditingController();

  bool loading = false;

  BottomTabController bottomTabController = Get.find();

  fetchBankDetails() async {
    Map bankDetails = await bottomTabController.userData["bankDetails"];

    bankNameController.text = bankDetails["bankName"];
    accountNumberController.text = bankDetails["accountNumber"];
    accountNameController.text = bankDetails["accountName"];
    branchController.text = bankDetails["branch"];
    swiftCodeController.text = bankDetails["swiftCode"];
  }

  @override
  void initState() {
    fetchBankDetails();
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    branchController.dispose();
    swiftCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Withdraw"),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: RichText(
                  text: TextSpan(
                    text: "\$${widget.amount}",
                    style: fontBody(
                        fontSize: 24.sp,
                        color: kWhiteColor,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                subtitle: Text("Available balance",
                    style: fontBody(
                        fontSize: 18.sp, color: kWhiteColor.withValues(alpha: 0.7))),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style:
                    customTextStyleBody(color: Colors.white, fontSize: 16.sp),
                decoration: InputDecoration(
                  fillColor: Colors.white10,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  labelText: "Enter Amount",
                  labelStyle:
                      customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter amount";
                  }
                  if (double.parse(value) < widget.minWithdraw) {
                    return "Minimum withdraw amount is \$${widget.minWithdraw}";
                  }
                  if (double.parse(value) > widget.amount) {
                    return "Insufficient balance";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Text("Bank details",
                  style: fontBody(
                      fontSize: 18.sp, color: kWhiteColor.withValues(alpha: 0.7))),
              const SizedBox(height: 15),
              TextFormField(
                controller: accountNameController,
                keyboardType: TextInputType.text,
                style:
                    customTextStyleBody(color: Colors.white, fontSize: 16.sp),
                decoration: InputDecoration(
                  fillColor: Colors.white10,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  labelText: "Account holder",
                  labelStyle:
                      customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter account holder name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: accountNumberController,
                keyboardType: TextInputType.text,
                style:
                    customTextStyleBody(color: Colors.white, fontSize: 16.sp),
                decoration: InputDecoration(
                  fillColor: Colors.white10,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  labelText: "Account number",
                  labelStyle:
                      customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter account number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: bankNameController,
                keyboardType: TextInputType.text,
                style:
                    customTextStyleBody(color: Colors.white, fontSize: 16.sp),
                decoration: InputDecoration(
                  fillColor: Colors.white10,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  labelText: "Bank name",
                  labelStyle:
                      customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter bank name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: branchController,
                keyboardType: TextInputType.text,
                style:
                    customTextStyleBody(color: Colors.white, fontSize: 16.sp),
                decoration: InputDecoration(
                  fillColor: Colors.white10,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  labelText: "Branch",
                  labelStyle:
                      customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter branch";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: swiftCodeController,
                keyboardType: TextInputType.text,
                style:
                    customTextStyleBody(color: Colors.white, fontSize: 16.sp),
                decoration: InputDecoration(
                  fillColor: Colors.white10,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  labelText: "Swift code",
                  labelStyle:
                      customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter swift code";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (loading) customCircularProgress(strokeColor: kButtonColor),
              if (!loading)
                GestureDetector(
                  onTap: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    setState(() {
                      loading = true;
                    });

                    double amount = double.parse(amountController.text);

                    await withdrawsCollection.add({
                      "amount": amount,
                      "accountName": accountNameController.text,
                      "accountNumber": accountNumberController.text,
                      "bankName": bankNameController.text,
                      "branch": branchController.text,
                      "swiftCode": swiftCodeController.text,
                      "uid": uid,
                      "status": "pending",
                      "date": DateTime.now(),
                    });

                    await usersCollection.doc(uid).update({
                      "wallet": FieldValue.increment(
                          (amount / widget.coinsValuation) * -1),
                      "bankDetails.accountName": accountNameController.text,
                      "bankDetails.accountNumber": accountNumberController.text,
                      "bankDetails.bankName": bankNameController.text,
                      "bankDetails.branch": branchController.text,
                      "bankDetails.swiftCode": swiftCodeController.text,
                    });

                    Get.back();
                    customSnackBar(text: "Withdraw request submitted");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xffdb3445), Color(0xfff71735)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text("Withdraw",
                        style: fontBody(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: kWhiteColor)),
                  ),
                ),
            ],
          ),
        ));
  }
}
