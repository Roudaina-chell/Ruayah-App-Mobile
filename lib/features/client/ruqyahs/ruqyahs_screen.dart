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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.veryLightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.headphones_rounded,
                        color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد رقيات متاحة حاليًا.',
                    style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: ruqyahs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
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
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9575CD), Color(0xFF5E35B1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isYoutube ? Icons.smart_display_rounded : Icons.music_note_rounded,
                  color: Colors.white,
                  size: 24,
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
                        fontWeight: FontWeight.w800,
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.navy],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}