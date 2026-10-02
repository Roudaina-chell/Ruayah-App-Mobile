import 'package:flutter/material.dart';

/// Design tokens for "محمد الراقي" — now theme-aware.
///
/// Every color is a *getter*, not a constant, so it can switch
/// between the light (warm teal + gold) and dark palette at
/// runtime. [darkModeNotifier] drives the switch; wrap the app's
/// root in a ValueListenableBuilder listening to it so the whole
/// tree rebuilds when it flips (see main.dart).
///
/// IMPORTANT: because these are no longer compile-time constants,
/// any widget that reads an AppColors value (directly, via
/// AppTextStyles' cardTitle/cardSubtitle, or via a gradient) must
/// NOT be wrapped in `const`. AppDecorations' methods were already
/// plain functions (not const), so they need no changes.
class AppColors {
  AppColors._();

  /// Toggle this (e.g. `AppColors.darkModeNotifier.value = true`)
  /// to switch every color below. Persist the choice yourself if
  /// you want it remembered between launches.
  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);

  static bool get isDark => darkModeNotifier.value;

  // ---- Brand ----
  static Color get teal => isDark ? const Color(0xFF4CAF9E) : const Color(0xFF0F5D54);
  static Color get tealDeep => isDark ? const Color(0xFF0B2320) : const Color(0xFF073934);
  static Color get tealSoft => isDark ? const Color(0xFF18332F) : const Color(0xFFE3EFEC);

  static Color get gold => isDark ? const Color(0xFFDDB663) : const Color(0xFFC69A43);
  static Color get goldDeep => isDark ? const Color(0xFFB68F44) : const Color(0xFF9C7527);
  static Color get goldSoft => isDark ? const Color(0xFF3A311E) : const Color(0xFFF6ECD6);

  // A second accent, reserved for admin dashboard stat differentiation
  // only — never used as a CTA color, so gold keeps its meaning.
  static Color get plum => isDark ? const Color(0xFFC191A4) : const Color(0xFF8B5468);
  static Color get plumSoft => isDark ? const Color(0xFF2E2126) : const Color(0xFFF1E4E8);

  // ---- Neutrals ----
  static Color get ink => isDark ? const Color(0xFFEDEAE2) : const Color(0xFF16302C);
  static Color get inkMuted => isDark ? const Color(0xFFB6C4C0) : const Color(0xFF5D716D);
  static Color get inkFaint => isDark ? const Color(0xFF7D8D89) : const Color(0xFF93A6A2);
  static Color get parchment => isDark ? const Color(0xFF0C1513) : const Color(0xFFFAF5EA);
  static Color get surface => isDark ? const Color(0xFF162220) : const Color(0xFFFFFEFB);
  static Color get white => isDark ? surface : const Color(0xFFFFFFFF);
  static Color get hairline => isDark ? const Color(0xFF2B3835) : const Color(0xFFE7DFCC);

  // ---- Status (kept in the same warm family) ----
  static Color get success => isDark ? const Color(0xFF6FBB92) : const Color(0xFF3D7A5C);
  static Color get successSoft => isDark ? const Color(0xFF1C3227) : const Color(0xFFE3EFE7);
  static Color get pending => isDark ? const Color(0xFFD8AC6D) : const Color(0xFFB8843A);
  static Color get pendingSoft => isDark ? const Color(0xFF362B19) : const Color(0xFFF5EAD8);
  static Color get danger => isDark ? const Color(0xFFDE8F82) : const Color(0xFFA34D3F);
  static Color get dangerSoft => isDark ? const Color(0xFF35201A) : const Color(0xFFF3E1DD);

  // ---- Gradients ----
  static LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [teal, tealDeep],
      );

  static LinearGradient get goldGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gold, goldDeep],
      );

  // ---- Legacy aliases ----
  // Safety net for any screen outside this redesign that still
  // references the old names — keeps it compiling, pulled into the
  // same teal/gold family instead of clashing with it.
  static Color get primary => teal;
  static Color get navy => ink;
  static Color get veryLightBlue => tealSoft;
}