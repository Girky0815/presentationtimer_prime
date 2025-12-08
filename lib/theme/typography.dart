import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle getSmartTextStyle({
  TextStyle? baseStyle,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  List<FontFeature>? fontFeatures,
  String? fallbackFamily,
}) {
  final defaultFallback = 'Quicksand';
  final targetFallback = fallbackFamily ?? defaultFallback;

  try {
    return GoogleFonts.getFont(
      'Google Sans Flex',
      textStyle: baseStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: fontFeatures,
    ).copyWith(
      fontFamilyFallback: [GoogleFonts.notoSansJp().fontFamily!],
    );
  } catch (e) {
    // Fallback to specified font (Quicksand or Roboto Mono)
    return GoogleFonts.getFont(
      targetFallback,
      textStyle: baseStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: fontFeatures,
    ).copyWith(
      fontFamilyFallback: [GoogleFonts.notoSansJp().fontFamily!],
    );
  }
}
