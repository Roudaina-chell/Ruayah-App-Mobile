import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ أثناء تحميل البرامج',
                style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5)),
              ),
            );
          }

          final programs = snapshot.data ?? [];

          if (programs.isEmpty) {
            return Center(
              child: Text(
                'لا توجد برامج متاحة حاليًا.',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: programs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final program = programs[index];
              return _ProgramTile(
                program: program,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
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
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
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
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.menu_book_outlined,
                    color: Color(0xFF00897B), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      program.shortDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.navy.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_new,
                  size: 15, color: AppColors.navy.withValues(alpha: 0.25)),
            ],
          ),
        ),
      ),
    );
  }
}