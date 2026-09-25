import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(label, style: AppTextStyles.label(color: AppColors.ink, size: 13)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.parchment, borderRadius: BorderRadius.circular(14)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            textAlign: TextAlign.right,
            style: AppTextStyles.body(size: 14.5),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.inkFaint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}