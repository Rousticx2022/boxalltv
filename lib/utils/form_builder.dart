import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../utils/styles.dart';
import 'ui_widgets.dart';

class Formbuilder {
  final TextEditingController controller;
  final dynamic validator;
  final dynamic onTap;
  final bool readOnly;
  final TextInputType inputType;
  final String pIcon;
  final String label;
  final int maxLines;

  final bool noPadding;

  Formbuilder({
    required this.controller,
    required this.validator,
    required this.inputType,
    this.readOnly = false,
    this.pIcon = "",
    this.maxLines = 1,
    required this.label,
    this.noPadding = false,
    this.onTap,
  });

  Widget buildTextField() {
    return Padding(
      padding: noPadding
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        onTap: onTap,
        maxLines: maxLines,
        controller: controller,
        keyboardType: inputType,
        readOnly: readOnly,
        style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
        decoration: InputDecoration(
          fillColor: Colors.white10,
          filled: true,
          prefixIcon: pIcon.isEmpty
              ? null
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset(pIcon, width: 5.w)],
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelText: label,
          labelStyle: customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
        ),
        validator: validator,
      ),
    );
  }

  Widget buildPasswordField(bool passwordVisible, var togglePassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.visiblePassword,
        obscureText: !passwordVisible,
        style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
        decoration: InputDecoration(
          fillColor: Colors.white10,
          filled: true,
          prefixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(pIcon, width: 5.w)],
          ),
          suffixIcon: IconButton(
            icon: Icon(
              passwordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            color: kWhiteColor.withValues(alpha: 0.7),
            onPressed: () {
              togglePassword();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelText: label,
          labelStyle: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
        ),
        validator: validator,
      ),
    );
  }

  Widget buildSelectField() {
    return Padding(
      padding: noPadding
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        readOnly: readOnly,
        onTap: onTap,
        style: customTextStyleBody(color: Colors.white, fontSize: 16.sp),
        decoration: InputDecoration(
          fillColor: Colors.white10,
          filled: true,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          prefixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(pIcon, width: 5.w)],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelText: label,
          labelStyle: customTextStyleBody(color: kWhiteColor, fontSize: 16.sp),
        ),
        validator: validator,
      ),
    );
  }
}
