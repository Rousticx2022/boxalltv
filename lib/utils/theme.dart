import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData customAppTheme = ThemeData(
  brightness: Brightness.dark,
  textSelectionTheme: const TextSelectionThemeData(cursorColor: kBlackColor),
  primaryColor: kWhiteColor,
  useMaterial3: false,
  scaffoldBackgroundColor: const Color(0xff000000),
  iconTheme: const IconThemeData(color: kWhiteColor),
  colorScheme: const ColorScheme.dark().copyWith(secondary: kWhiteColor),
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    centerTitle: false,
    titleTextStyle: GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);
