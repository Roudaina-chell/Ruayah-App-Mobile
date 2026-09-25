import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/patient_case.dart';
import '../../../models/case_entry.dart';
import '../../../services/auth_service.dart';
import '../../../services/case_service.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  final _caseService = CaseService();
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _symptomController = TextEditingController();
  final _scrollController = ScrollController();

  bool _nameInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _caseService.markSeenByClient();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symptomController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveName(String phone) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await _caseService.updateClientName(userName: name, userPhone: phone);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text('تم حفظ الاسم', textAlign: TextAlign.right),
        ),
      );
    }
  }

  Future<void> _handleSendSymptom() async {
    final text = _symptomController.text.trim();
    if (text.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    _symptomController.clear();

    try {
      await _caseService.addSymptomEntry(text);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.parchment,
        child: StreamBuilder<PatientCase?>(
          stream: _caseService.myCase(),
          builder: (context, caseSnapshot) {
            final patientCase = caseSnapshot.data;

            if (!_nameInitialized) {
              _nameInitialized = true;
              _nameController.text = patientCase?.userName ?? '';
            }

            return FutureBuilder(
              future: _authService.getCurrentUserProfile(),
              builder: (context, profileSnapshot) {
                final phone = profileSnapshot.data?.phone ?? '';
                final hasDiagnosis = patientCase?.diagnosis.isNotEmpty ?? false;
                final trimmedName = _nameController.text.trim();
                final initial = trimmedName.isNotEmpty
                    ? trimmedName.substring(0, 1)
                    : '؟';

                return Column(
                  children: [
                    // ===== Patient snapshot card =====
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      padding: const EdgeInsets.all(18),
                      decoration: AppDecorations.card(radius: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: AppColors.heroGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.teal.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  initial,
                                  style: AppTextStyles.heading(
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'المريض',
                                      style: AppTextStyles.label(size: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    TextField(
                                      controller: _nameController,
                                      textAlign: TextAlign.right,
                                      onChanged: (_) => setState(() {}),
                                      style: AppTextStyles.heading(size: 16),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        hintText: 'اكتب اسمك',
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.tealSoft,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.teal,
                                    size: 19,
                                  ),
                                  onPressed: () => _saveName(phone),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: hasDiagnosis
                                  ? AppColors.goldSoft
                                  : AppColors.parchment,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.medical_services_rounded,
                                  size: 18,
                                  color: hasDiagnosis
                                      ? AppColors.goldDeep
                                      : AppColors.inkFaint,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'التشخيص',
                                        style: AppTextStyles.label(size: 11),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        hasDiagnosis
                                            ? patientCase!.diagnosis
                                            : 'لم يتم تحديد التشخيص بعد',
                                        textAlign: TextAlign.right,
                                        style: hasDiagnosis
                                            ? AppTextStyles.heading(
                                                color: AppColors.goldDeep,
                                                size: 13.5,
                                              )
                                            : AppTextStyles.body(
                                                color: AppColors.inkFaint,
                                                size: 13.5,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الأعراض الحالية',
                              style: AppTextStyles.heading(size: 13.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Expanded(
                      child: StreamBuilder<List<CaseEntry>>(
                        stream: _caseService.entries(
                          _authService.currentUser?.uid ?? '',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.teal,
                              ),
                            );
                          }

                          final entries = snapshot.data ?? [];

                          if (entries.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 68,
                                      height: 68,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        color: AppColors.tealSoft,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: AppColors.teal,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لم تسجل أي أعراض بعد.\nاكتب أعراضك الحالية بالأسفل.',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.body(
                                        color: AppColors.inkFaint,
                                        size: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          _scrollToBottom();

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              return _EntryCard(entry: entries[index]);
                            },
                          );
                        },
                      ),
                    ),

                    // ===== Floating input pill =====
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.teal.withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.tealDeep.withValues(alpha: 0.1),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 8,
                                  top: 6,
                                  bottom: 6,
                                ),
                                child: TextField(
                                  controller: _symptomController,
                                  textAlign: TextAlign.right,
                                  maxLines: 4,
                                  minLines: 1,
                                  style: AppTextStyles.body(size: 14),
                                  decoration: InputDecoration(
                                    hintText: 'اكتب أعراضك...',
                                    hintStyle: TextStyle(
                                      color: AppColors.inkFaint,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                onPressed: _isSaving
                                    ? null
                                    : _handleSendSymptom,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final CaseEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isAdmin = entry.authorRole == 'admin';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isAdmin
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAdmin) ...[
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                color: AppColors.tealSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 15,
                color: AppColors.teal,
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isAdmin ? null : AppColors.heroGradient,
                color: isAdmin ? AppColors.surface : null,
                border: isAdmin
                    ? Border.all(color: AppColors.teal.withValues(alpha: 0.07))
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isAdmin ? 4 : 18),
                  bottomRight: Radius.circular(isAdmin ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tealDeep.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAdmin ? 'توجيه الراقي' : 'أعراضك',
                    style: AppTextStyles.label(
                      color: isAdmin
                          ? AppColors.goldDeep
                          : Colors.white.withValues(alpha: 0.85),
                      size: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.text,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body(
                      color: isAdmin ? AppColors.ink : Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
