import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynotes/constants/pallete.dart';

class TStyle {
  static TextStyle placeholder = GoogleFonts.poppins()
      .copyWith(color: const Color.fromRGBO(120, 119, 119, 1));

  static TextStyle lightButton =
      GoogleFonts.poppins().copyWith(color: Pallete.whiteColor, fontSize: 15);

  static TextStyle darkButton =
      GoogleFonts.poppins().copyWith(color: Pallete.darkColor, fontSize: 15);

  static TextStyle accentButton =
      GoogleFonts.poppins().copyWith(color: Pallete.accentColor, fontSize: 15);

  static TextStyle heading1 =
      GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w500);

  static TextStyle heading2 =
      GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w300);

  static TextStyle bodyExtraSmall =
      const TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
}
