import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final ruqyahs = snapshot.data ?? [];

          if (ruqyahs.isEmpty) {
            return Center(
              child: Text(
                'لا توجد رقيات متاحة حاليًا.',
                style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 14),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: ruqyahs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ruqyah = ruqyahs[index];
              return _RuqyahTile(
                ruqyah: ruqyah,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RuqyahPlayerScreen(ruqyah: ruqyah)),
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
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isYoutube ? Icons.smart_display_outlined : Icons.music_note_outlined,
                  color: const Color(0xFF7E57C2),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ruqyah.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isYoutube ? 'يوتيوب' : 'ملف صوتي',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.navy.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}