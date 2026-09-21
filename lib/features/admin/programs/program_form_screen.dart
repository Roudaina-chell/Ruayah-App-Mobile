import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/program.dart';
import '../../../services/program_service.dart';

class ProgramFormScreen extends StatefulWidget {
  final Program? program; // null = إضافة جديد، غير null = تعديل

  const ProgramFormScreen({super.key, this.program});

  @override
  State<ProgramFormScreen> createState() => _ProgramFormScreenState();
}

class _ProgramFormScreenState extends State<ProgramFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _contentController;
  final _service = ProgramService();
  bool _isLoading = false;

  bool get _isEditing => widget.program != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.program?.title ?? '');
    _shortDescController =
        TextEditingController(text: widget.program?.shortDescription ?? '');
    _contentController = TextEditingController(text: widget.program?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final shortDesc = _shortDescController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || shortDesc.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء ملء جميع الحقول', textAlign: TextAlign.right)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await _service.updateProgram(
          programId: widget.program!.id,
          title: title,
          shortDescription: shortDesc,
          content: content,
        );
      } else {
        await _service.addProgram(
          title: title,
          shortDescription: shortDesc,
          content: content,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(
          _isEditing ? 'تعديل البرنامج' : 'إضافة برنامج',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('اسم البرنامج'),
              const SizedBox(height: 8),
              _buildTextField(_titleController, 'مثلاً: برنامج العين'),
              const SizedBox(height: 18),

              _buildLabel('وصف قصير'),
              const SizedBox(height: 8),
              _buildTextField(_shortDescController, 'وصف مختصر يظهر في القائمة'),
              const SizedBox(height: 18),

              _buildLabel('المحتوى'),
              const SizedBox(height: 8),
              _buildTextField(_contentController, 'التفاصيل الكاملة للبرنامج', maxLines: 8),

              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'حفظ التعديلات' : 'حفظ البرنامج',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlign: TextAlign.right,
        style: TextStyle(color: AppColors.navy, fontSize: 14.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.35)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}