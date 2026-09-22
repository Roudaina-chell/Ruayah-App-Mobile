import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        color: const Color(0xFFF7F9FB),
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

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFieldBox(
                            label: 'الاسم',
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(color: AppColors.navy, fontSize: 14),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'اكتب اسمك',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.check_circle_rounded,
                                      color: AppColors.primary, size: 20),
                                  onPressed: () => _saveName(phone),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildFieldBox(
                            label: 'تشخيصك عند الرقية',
                            child: Text(
                              (patientCase?.diagnosis.isNotEmpty ?? false)
                                  ? patientCase!.diagnosis
                                  : 'لم يتم تحديد التشخيص بعد',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: (patientCase?.diagnosis.isNotEmpty ?? false)
                                    ? AppColors.navy
                                    : AppColors.navy.withValues(alpha: 0.4),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 15,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الأعراض الحالية',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: StreamBuilder<List<CaseEntry>>(
                        stream: _caseService.entries(
                            _authService.currentUser?.uid ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
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
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: AppColors.veryLightBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.chat_bubble_outline_rounded,
                                          color: AppColors.primary, size: 26),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'لم تسجل أي أعراض بعد.\nاكتب أعراضك الحالية بالأسفل.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.navy.withValues(alpha: 0.4),
                                        fontSize: 13,
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
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              return _EntryCard(entry: entries[index]);
                            },
                          );
                        },
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                              color: AppColors.navy.withValues(alpha: 0.06)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F8FC),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: TextField(
                                controller: _symptomController,
                                textAlign: TextAlign.right,
                                maxLines: 3,
                                minLines: 1,
                                style:
                                    TextStyle(color: AppColors.navy, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'اكتب أعراضك...',
                                  hintStyle: TextStyle(
                                      color: AppColors.navy.withValues(alpha: 0.35)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 46,
                            height: 46,
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
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded, color: Colors.white, size: 19),
                              onPressed: _isSaving ? null : _handleSendSymptom,
                            ),
                          ),
                        ],
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

  Widget _buildFieldBox({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.navy.withValues(alpha: 0.45),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final CaseEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isAdmin = entry.authorRole == 'admin';

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isAdmin
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.navy],
                ),
          color: isAdmin ? Colors.white : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 4 : 16),
            bottomRight: Radius.circular(isAdmin ? 16 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                if (isAdmin) ...[
                  Icon(Icons.medical_services_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                ],
                Text(
                  isAdmin ? 'توجيه الراقي' : 'أعراضك',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isAdmin
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              entry.text,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isAdmin ? AppColors.navy : Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}