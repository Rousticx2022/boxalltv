import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/user_service.dart';
import '../utils/form_builder.dart';
import '../utils/form_validators.dart';

class ResetPassword extends StatefulWidget {
  final String? email;
  const ResetPassword({super.key, this.email});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  @override
  void initState() {
    if (widget.email != null || widget.email!.isNotEmpty) {
      emailController.text = widget.email!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Reset Password'),
      ),
      body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Formbuilder(
                      controller: emailController,
                      validator: emailValidator,
                      inputType: TextInputType.emailAddress,
                      pIcon: "assets/email_icon.png",
                      label: "Enter registered email address")
                  .buildTextField(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: kWhiteColor,
                    backgroundColor: kButtonColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: loading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              customCircularProgress(strokeColor: kWhiteColor))
                      : const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () async {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    setState(() {
                      loading = true;
                    });

                    bool status = await UserService.instance
                        .resetPassword(emailController.text);
                    if (status) {
                      Get.back();
                      customSnackBar(
                          text:
                              "Password reset link sent on ${emailController.text}");
                    } else {
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  label: const Text("Send reset link",
                      style: TextStyle(color: Color(0xffe0e0e0))),
                ),
              ),
            ],
          )),
    );
  }
}
