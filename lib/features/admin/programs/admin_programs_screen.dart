import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../models/program.dart';
import '../../../services/program_service.dart';
import 'program_form_screen.dart';

class AdminProgramsScreen extends StatelessWidget {
  const AdminProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ProgramService();

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text(
          'إدارة البرامج العلاجية',
          style: AppTextStyles.heading(size: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.teal),
            onPressed: () {
              Navigator.of(
                context,
              ).push(AppPageRoute(builder: (_) => const ProgramFormScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Program>>(
          stream: service.allPrograms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              );
            }

            final programs = snapshot.data ?? [];

            if (programs.isEmpty) {
              return const EmptyState(
                icon: Icons.menu_book_outlined,
                message: 'لا توجد برامج بعد. اضغط + لإضافة برنامج.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: programs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final program = programs[index];
                return _AdminProgramTile(program: program, service: service);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdminProgramTile extends StatelessWidget {
  final Program program;
  final ProgramService service;

  const _AdminProgramTile({required this.program, required this.service});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'حذف البرنامج',
      message: 'هل أنت متأكد من حذف "${program.title}"؟',
      confirmLabel: 'حذف',
    );

    if (confirmed) {
      await service.deleteProgram(program.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(radius: 18),
      child: Row(
        children: [
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
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.inkMuted,
              size: 20,
            ),
            onPressed: () {
              Navigator.of(context).push(
                AppPageRoute(
                  builder: (_) => ProgramFormScreen(program: program),
                ),
              );
            },
          ),
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
