import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/widgets/app_text_field.dart';
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
    _shortDescController = TextEditingController(
      text: widget.program?.shortDescription ?? '',
    );
    _contentController = TextEditingController(
      text: widget.program?.content ?? '',
    );
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
        SnackBar(
          content: Text('الرجاء ملء جميع الحقول', textAlign: TextAlign.right),
        ),
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
        SnackBar(
          content: Text('حدث خطأ، حاول مرة أخرى', textAlign: TextAlign.right),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(
          _isEditing ? 'تعديل البرنامج' : 'إضافة برنامج',
          style: AppTextStyles.heading(size: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'اسم البرنامج',
                controller: _titleController,
                hint: 'مثلاً: برنامج العين',
              ),
              const SizedBox(height: 18),

              AppTextField(
                label: 'وصف قصير',
                controller: _shortDescController,
                hint: 'وصف مختصر يظهر في القائمة',
              ),
              const SizedBox(height: 18),

              AppTextField(
                label: 'المحتوى',
                controller: _contentController,
                hint: 'التفاصيل الكاملة للبرنامج',
                maxLines: 8,
              ),

              const SizedBox(height: 28),

              Container(
                height: 54,
                decoration: AppDecorations.goldButton(radius: 14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _isLoading ? null : _handleSave,
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _isEditing ? 'حفظ التعديلات' : 'حفظ البرنامج',
                              style: AppTextStyles.button(size: 15),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
