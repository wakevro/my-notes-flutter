import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynotes/constants/pallete.dart';

class TStyle {
  static TextStyle placeholder = GoogleFonts.plusJakartaSans()
      .copyWith(color: const Color.fromRGBO(120, 119, 119, 1));

  static TextStyle lightButton = GoogleFonts.plusJakartaSans()
      .copyWith(color: Pallete.whiteColor, fontSize: 15);

  static TextStyle darkButton = GoogleFonts.plusJakartaSans()
      .copyWith(color: Pallete.darkColor, fontSize: 15);

  static TextStyle accentButton = GoogleFonts.plusJakartaSans()
      .copyWith(color: Pallete.accentColor, fontSize: 15);

  static TextStyle heading1 =
      GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w500);

  static TextStyle heading2 =
      GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w300);

  static TextStyle bodyExtraSmall =
      GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w300);

  static TextStyle bodyMedium =
      GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w300);
}
