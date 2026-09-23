import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Two-family type system.
///
/// Aref Ruqaa — a genuine Ruqaa calligraphy revival — carries the few
/// moments that should feel handwritten and warm (the app name, the
/// greeting, section leads). Cairo runs everything else so the
/// day-to-day interface stays clean and easy to read.
class AppTextStyles {
  AppTextStyles._();

  // ---- Calligraphic display — spend this sparingly ----
  static TextStyle display({Color color = AppColors.white, double size = 30}) =>
      GoogleFonts.arefRuqaa(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.15,
      );

  static TextStyle displaySmall({Color color = AppColors.ink, double size = 22}) =>
      GoogleFonts.arefRuqaa(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.25,
      );

  // ---- Cairo — interface & body ----
  static TextStyle heading({Color color = AppColors.ink, double size = 16}) =>
      GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.1,
      );

  static final TextStyle cardTitle = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.1,
  );

  static final TextStyle cardSubtitle = GoogleFonts.cairo(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMuted,
  );

  static TextStyle body({Color color = AppColors.ink, double size = 14.5}) =>
      GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.65,
      );

  static TextStyle label({Color color = AppColors.inkMuted, double size = 12}) =>
      GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle button({Color color = AppColors.white, double size = 15.5}) =>
      GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
      );
}