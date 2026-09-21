import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.navy,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 14,
    color: AppColors.navy,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.navy,
  );

  static TextStyle cardSubtitle = TextStyle(
    fontSize: 12,
    color: AppColors.navy.withValues(alpha: 0.6),
  );
}