import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/patient_case.dart';
import '../../../services/case_service.dart';
import 'admin_case_detail_screen.dart';

class AdminCasesScreen extends StatelessWidget {
  const AdminCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseService = CaseService();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'متابعة الحالات',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<PatientCase>>(
          stream: caseService.allCases(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final cases = snapshot.data ?? [];

            if (cases.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد حالات أو رسائل جديدة.',
                  style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 14),
                ),
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
                      MaterialPageRoute(
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
                decoration: BoxDecoration(color: AppColors.veryLightBlue, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    _initial,
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientCase.userName.isNotEmpty ? patientCase.userName : 'بدون اسم',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      patientCase.diagnosis.isNotEmpty
                          ? patientCase.diagnosis
                          : 'لم يتم تحديد التشخيص',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: AppColors.navy.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              if (patientCase.hasUnreadForAdmin)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Color(0xFF1976D2), shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}