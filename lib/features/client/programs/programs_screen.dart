import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/program.dart';
import '../../../services/program_service.dart';
import 'program_detail_screen.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ProgramService();

    return SafeArea(
      child: StreamBuilder<List<Program>>(
        stream: service.allPrograms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }

          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline_rounded,
              message: 'حدث خطأ أثناء تحميل البرامج',
            );
          }

          final programs = snapshot.data ?? [];

          if (programs.isEmpty) {
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              message: 'لا توجد برامج متاحة حاليًا.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: programs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final program = programs[index];
              return _ProgramTile(
                program: program,
                onTap: () {
                  Navigator.of(context).push(
                    AppPageRoute(
                      builder: (_) => ProgramDetailScreen(program: program),
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

class _ProgramTile extends StatelessWidget {
  final Program program;
  final VoidCallback onTap;

  const _ProgramTile({required this.program, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        splashColor: AppColors.gold.withValues(alpha: 0.1),
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card(radius: 22),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: AppColors.teal, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(program.title, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 3),
                    Text(
                      program.shortDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 13, color: AppColors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}