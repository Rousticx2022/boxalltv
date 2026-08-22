import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../controllers/signup_controller.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import '../utils/form_builder.dart';
import '../utils/form_validators.dart';
import '../utils/styles.dart';

class Signup extends GetView<SignupController> {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: kToolbarHeight),
        children: [
          Center(child: Image.asset("assets/logo.jpg", width: 40.w)),
          Padding(
            padding: EdgeInsets.only(top: 2.h, bottom: 20),
            child: Text(
              "Welcome!",
              textAlign: TextAlign.center,
              style: customTextStyleHeadline(fontSize: 22.sp),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Create a new account",
              textAlign: TextAlign.center,
              style: customTextStyleBody(
                color: Colors.grey.shade300,
                fontSize: 16.sp,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Formbuilder(
                  controller: controller.usernameController,
                  validator: nameValidator,
                  inputType: TextInputType.name,
                  pIcon: "assets/user_icon.png",
                  label: "Enter Username",
                ).buildTextField(),
                Formbuilder(
                  controller: controller.emailController,
                  validator: emailValidator,
                  inputType: TextInputType.emailAddress,
                  pIcon: "assets/email_icon.png",
                  label: "Enter Email",
                ).buildTextField(),
                Formbuilder(
                  controller: controller.countryController,
                  readOnly: true,
                  validator: countryValidator,
                  inputType: TextInputType.text,
                  pIcon: "assets/location_icon.png",
                  onTap: controller.selectCountry,
                  label: "Select Country",
                ).buildSelectField(),
                Formbuilder(
                  controller: controller.zipcodeController,
                  validator: fieldValidator,
                  inputType: TextInputType.text,
                  readOnly: true,
                  onTap: () => controller.openZipcodeSheet(),
                  pIcon: "assets/zipcode_icon.png",
                  label: "Enter Zipcode",
                ).buildTextField(),
                Obx(
                  () =>
                      Formbuilder(
                        controller: controller.passwordController,
                        validator: passwordValidator,
                        inputType: TextInputType.visiblePassword,
                        pIcon: "assets/lock_icon.png",
                        label: "Enter Password",
                      ).buildPasswordField(
                        controller.passwordVisible.value,
                        controller.togglePassword,
                      ),
                ),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.emailPasswordSignup(),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        controller.loading.value
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Image.asset(
                                  "assets/button_anim.gif",
                                  width: context.width - 40,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Image.asset(
                                  "assets/button.png",
                                  width: context.width - 40,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        Text(
                          "SIGNUP",
                          style: fontButton(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            shadows: [
                              Shadow(
                                color: kBlackColor.withValues(alpha: 0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: customTextStyleBody(
                        fontSize: 16.sp,
                        color: kWhiteColor,
                      ),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: customTextStyleBody(
                            fontSize: 16.sp,
                            color: kWhiteColor.withValues(alpha: 0.7),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.back();
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
