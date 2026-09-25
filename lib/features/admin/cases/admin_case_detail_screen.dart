import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../models/patient_case.dart';
import '../../../models/case_entry.dart';
import '../../../services/case_service.dart';

class AdminCaseDetailScreen extends StatefulWidget {
  final PatientCase patientCase;

  const AdminCaseDetailScreen({super.key, required this.patientCase});

  @override
  State<AdminCaseDetailScreen> createState() => _AdminCaseDetailScreenState();
}

class _AdminCaseDetailScreenState extends State<AdminCaseDetailScreen> {
  final _caseService = CaseService();
  final _diagnosisController = TextEditingController();
  final _guidanceController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _diagnosisController.text = widget.patientCase.diagnosis;
    _caseService.markSeenByAdmin(widget.patientCase.id);
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _guidanceController.dispose();
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

  Future<void> _saveDiagnosis() async {
    final text = _diagnosisController.text.trim();
    await _caseService.updateDiagnosis(caseId: widget.patientCase.id, diagnosis: text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ التشخيص', textAlign: TextAlign.right)),
      );
    }
  }

  Future<void> _handleSendGuidance() async {
    final text = _guidanceController.text.trim();
    if (text.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    _guidanceController.clear();

    try {
      await _caseService.addGuidanceEntry(caseId: widget.patientCase.id, text: text);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Column(
          children: [
            Text(
              widget.patientCase.userName.isNotEmpty ? widget.patientCase.userName : 'بدون اسم',
              style: AppTextStyles.heading(size: 15),
            ),
            Text(widget.patientCase.userPhone, style: AppTextStyles.label(color: AppColors.inkFaint, size: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('تشخيصك عند الرقية', style: AppTextStyles.label(color: AppColors.inkFaint, size: 12)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.goldSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _diagnosisController,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.body(color: AppColors.goldDeep, size: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'اكتب التشخيص هنا',
                              hintStyle: TextStyle(color: AppColors.goldDeep.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                          onPressed: _saveDiagnosis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('الأعراض والتوجيهات', style: AppTextStyles.heading(size: 13.5)),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<CaseEntry>>(
                stream: _caseService.entries(widget.patientCase.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                  }

                  final entries = snapshot.data ?? [];

                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد أعراض مسجلة بعد.',
                        style: AppTextStyles.body(color: AppColors.inkFaint, size: 13),
                      ),
                    );
                  }

                  _scrollToBottom();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return _EntryCard(entry: entries[index]);
                    },
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.teal.withValues(alpha: 0.07))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.parchment,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _guidanceController,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        minLines: 1,
                        style: AppTextStyles.body(size: 14),
                        decoration: InputDecoration(
                          hintText: 'اكتب التوجيه...',
                          hintStyle: TextStyle(color: AppColors.inkFaint),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: IconButton(
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: _isSaving ? null : _handleSendGuidance,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isAdmin) ...[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(color: AppColors.tealSoft, shape: BoxShape.circle),
              child: const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.teal),
            ),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isAdmin ? AppColors.heroGradient : null,
                color: isAdmin ? null : AppColors.surface,
                border: isAdmin ? null : Border.all(color: AppColors.teal.withValues(alpha: 0.07)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isAdmin ? 18 : 4),
                  bottomRight: Radius.circular(isAdmin ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(color: AppColors.tealDeep.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAdmin ? 'توجيهك' : 'أعراض المريض',
                    style: AppTextStyles.label(
                      color: isAdmin ? Colors.white.withValues(alpha: 0.85) : AppColors.inkFaint,
                      size: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.text,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body(color: isAdmin ? Colors.white : AppColors.ink, size: 14),
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