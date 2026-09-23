import 'package:flutter/material.dart';

/// Design tokens for "محمد الراقي".
///
/// A warm, grounded palette: deep teal drawn from Islamic tilework,
/// paired with an aged-gold accent used the way gold leaf is used in
/// illuminated manuscripts — sparingly, to mark what matters.
class AppColors {
  AppColors._();

  // ---- Brand ----
  static const Color teal = Color(0xFF0F5D54);
  static const Color tealDeep = Color(0xFF073934);
  static const Color tealSoft = Color(0xFFE3EFEC);

  static const Color gold = Color(0xFFC69A43);
  static const Color goldDeep = Color(0xFF9C7527);
  static const Color goldSoft = Color(0xFFF6ECD6);

  // ---- Neutrals ----
  static const Color ink = Color(0xFF16302C);
  static const Color inkMuted = Color(0xFF5D716D);
  static const Color inkFaint = Color(0xFF93A6A2);
  static const Color parchment = Color(0xFFFAF5EA);
  static const Color surface = Color(0xFFFFFEFB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFE7DFCC);

  // ---- Status (kept in the same warm family) ----
  static const Color success = Color(0xFF3D7A5C);
  static const Color successSoft = Color(0xFFE3EFE7);
  static const Color pending = Color(0xFFB8843A);
  static const Color pendingSoft = Color(0xFFF5EAD8);
  static const Color danger = Color(0xFFA34D3F);
  static const Color dangerSoft = Color(0xFFF3E1DD);

  // ---- Gradients ----
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [teal, tealDeep],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldDeep],
  );
}