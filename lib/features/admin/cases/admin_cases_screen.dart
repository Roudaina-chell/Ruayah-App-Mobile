import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../models/patient_case.dart';
import '../../../services/case_service.dart';
import 'admin_case_detail_screen.dart';

class AdminCasesScreen extends StatelessWidget {
  const AdminCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseService = CaseService();

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        title: Text('متابعة الحالات', style: AppTextStyles.heading(size: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<PatientCase>>(
          stream: caseService.allCases(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.teal));
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'خطأ: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label(color: AppColors.danger, size: 12),
                  ),
                ),
              );
            }

            final cases = snapshot.data ?? [];

            if (cases.isEmpty) {
              return const EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                message: 'لا توجد حالات أو رسائل جديدة.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: cases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final patientCase = cases[index];
                return _CaseTile(
                  patientCase: patientCase,
                  onTap: () {
                    Navigator.of(context).push(
                      AppPageRoute(
                        builder: (_) => AdminCaseDetailScreen(patientCase: patientCase),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CaseTile extends StatelessWidget {
  final PatientCase patientCase;
  final VoidCallback onTap;

  const _CaseTile({required this.patientCase, required this.onTap});

  String get _initial =>
      patientCase.userName.isNotEmpty ? patientCase.userName[0] : '؟';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.gold.withValues(alpha: 0.1),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppDecorations.card(radius: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.tealSoft, shape: BoxShape.circle),
                child: Center(
                  child: Text(_initial, style: AppTextStyles.heading(color: AppColors.teal, size: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientCase.userName.isNotEmpty ? patientCase.userName : 'بدون اسم',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      patientCase.diagnosis.isNotEmpty ? patientCase.diagnosis : 'لم يتم تحديد التشخيص',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
              if (patientCase.hasUnreadForAdmin)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}