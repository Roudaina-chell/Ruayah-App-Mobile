import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../models/ruqyah.dart';
import '../../../services/ruqyah_service.dart';
import 'ruqyah_form_screen.dart';

class AdminRuqyahsScreen extends StatelessWidget {
  const AdminRuqyahsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = RuqyahService();

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text(
          'إدارة الرقيات المسموعة',
          style: AppTextStyles.heading(size: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.teal),
            onPressed: () {
              Navigator.of(
                context,
              ).push(AppPageRoute(builder: (_) => const RuqyahFormScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Ruqyah>>(
          stream: service.allRuqyahs(),
          builder: (context, snapshot) {
            final ruqyahs = snapshot.data ?? [];

            if (ruqyahs.isEmpty) {
              return const EmptyState(
                icon: Icons.headphones_rounded,
                message: 'لا توجد رقيات بعد. اضغط + لإضافة رقية.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: ruqyahs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ruqyah = ruqyahs[index];
                return _AdminRuqyahTile(ruqyah: ruqyah, service: service);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdminRuqyahTile extends StatelessWidget {
  final Ruqyah ruqyah;
  final RuqyahService service;

  const _AdminRuqyahTile({required this.ruqyah, required this.service});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'حذف الرقية',
      message: 'هل أنت متأكد من حذف "${ruqyah.title}"؟',
      confirmLabel: 'حذف',
    );

    if (confirmed) {
      await service.deleteRuqyah(ruqyah.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isYoutube = ruqyah.type == 'youtube';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(radius: 18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.plumSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isYoutube
                  ? Icons.smart_display_rounded
                  : Icons.music_note_rounded,
              color: AppColors.plum,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(ruqyah.title, style: AppTextStyles.cardTitle)),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
              size: 20,
            ),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}
