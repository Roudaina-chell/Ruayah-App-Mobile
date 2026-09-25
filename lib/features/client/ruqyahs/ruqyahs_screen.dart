import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/ruqyah.dart';
import '../../../services/ruqyah_service.dart';
import 'ruqyah_player_screen.dart';

class RuqyahsScreen extends StatelessWidget {
  const RuqyahsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = RuqyahService();

    return SafeArea(
      child: StreamBuilder<List<Ruqyah>>(
        stream: service.allRuqyahs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }

          final ruqyahs = snapshot.data ?? [];

          if (ruqyahs.isEmpty) {
            return const EmptyState(
              icon: Icons.headphones_rounded,
              message: 'لا توجد رقيات متاحة حاليًا.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: ruqyahs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ruqyah = ruqyahs[index];
              return _RuqyahTile(
                ruqyah: ruqyah,
                onTap: () {
                  Navigator.of(context).push(
                    AppPageRoute(
                      builder: (_) => RuqyahPlayerScreen(ruqyah: ruqyah),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _RuqyahTile extends StatelessWidget {
  final Ruqyah ruqyah;
  final VoidCallback onTap;

  const _RuqyahTile({required this.ruqyah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isYoutube = ruqyah.type == 'youtube';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        splashColor: AppColors.gold.withValues(alpha: 0.1),
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppDecorations.card(radius: 22),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Icon(
                  isYoutube
                      ? Icons.smart_display_rounded
                      : Icons.music_note_rounded,
                  color: AppColors.teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ruqyah.title, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 3),
                    Text(
                      isYoutube ? 'يوتيوب' : 'ملف صوتي',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
