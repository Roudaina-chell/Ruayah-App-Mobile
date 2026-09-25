import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A single, on-brand confirm dialog for destructive actions —
/// replaces the plain default [AlertDialog] used in a couple of
/// admin list screens.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأكيد',
  String cancelLabel = 'إلغاء',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: AppTextStyles.heading(size: 16)),
      content: Text(
        message,
        textAlign: TextAlign.right,
        style: AppTextStyles.body(color: AppColors.inkMuted, size: 13.5),
      ),
      actionsAlignment: MainAxisAlignment.start,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel, style: AppTextStyles.label(color: AppColors.danger, size: 14)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel, style: AppTextStyles.label(color: AppColors.inkMuted, size: 14)),
        ),
      ],
    ),
  );
  return result == true;
}