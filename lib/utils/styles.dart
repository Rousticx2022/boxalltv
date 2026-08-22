import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle customTextStyleHeadline({
  Color color = Colors.white,
  double fontSize = 20,
  FontWeight fontWeight = FontWeight.bold,
}) {
  return GoogleFonts.catamaran(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}

TextStyle customTextStyleBody({
  Color color = Colors.white,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
}) {
  return GoogleFonts.inter(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}

var fontPoppins = GoogleFonts.poppins;
var fontButton = GoogleFonts.kanit;
var fontBody = GoogleFonts.inter;
var fontHeading = GoogleFonts.catamaran;

// // stream
// var fontHeading = GoogleFonts.orbitron;
// var fontStreamBody = GoogleFonts.montserratAlternates;
//
// // social
// var fontHeading = GoogleFonts.pacifico;
// var fontBody = GoogleFonts.comfortaa;
