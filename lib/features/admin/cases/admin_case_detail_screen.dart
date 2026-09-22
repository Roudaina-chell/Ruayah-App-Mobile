import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        title: Column(
          children: [
            Text(
              widget.patientCase.userName.isNotEmpty
                  ? widget.patientCase.userName
                  : 'بدون اسم',
              style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              widget.patientCase.userPhone,
              style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 11),
            ),
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
                    child: Text(
                      'تشخيصك عند الرقية',
                      style: TextStyle(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.45)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _diagnosisController,
                            textAlign: TextAlign.right,
                            style: TextStyle(color: AppColors.navy, fontSize: 14),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'اكتب التشخيص هنا',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.check, color: Colors.white, size: 18),
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
                child: Text(
                  'الأعراض والتوجيهات',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<CaseEntry>>(
                stream: _caseService.entries(widget.patientCase.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final entries = snapshot.data ?? [];

                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد أعراض مسجلة بعد.',
                        style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 13),
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
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.navy.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _guidanceController,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        minLines: 1,
                        style: TextStyle(color: AppColors.navy, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'اكتب التوجيه...',
                          hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.35)),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
                          : const Icon(Icons.send, color: Colors.white, size: 18),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.veryLightBlue : const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(14),
        border: isAdmin ? Border.all(color: AppColors.primary.withValues(alpha: 0.2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              if (isAdmin) ...[
                Icon(Icons.medical_services_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
              ],
              Text(
                isAdmin ? 'توجيهك' : 'أعراض المريض',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isAdmin ? AppColors.primary : AppColors.navy.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.text,
            textAlign: TextAlign.right,
            style: TextStyle(color: AppColors.navy, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}