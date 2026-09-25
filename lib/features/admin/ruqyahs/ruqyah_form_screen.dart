import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../services/ruqyah_service.dart';

class RuqyahFormScreen extends StatefulWidget {
  const RuqyahFormScreen({super.key});

  @override
  State<RuqyahFormScreen> createState() => _RuqyahFormScreenState();
}

class _RuqyahFormScreenState extends State<RuqyahFormScreen> {
  final _titleController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _service = RuqyahService();

  String _type = 'youtube'; // youtube | audio
  File? _pickedFile;
  String? _pickedFileName;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _pickedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showSnack('الرجاء إدخال اسم الرقية');
      return;
    }

    if (_type == 'youtube' && _youtubeController.text.trim().isEmpty) {
      _showSnack('الرجاء إدخال رابط اليوتيوب');
      return;
    }

    if (_type == 'audio' && _pickedFile == null) {
      _showSnack('الرجاء اختيار ملف صوتي');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_type == 'youtube') {
        await _service.addYoutubeRuqyah(
          title: title,
          youtubeUrl: _youtubeController.text.trim(),
        );
      } else {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$_pickedFileName';
        final url = await _service.uploadAudioFile(_pickedFile!, fileName);
        await _service.addAudioRuqyah(title: title, audioUrl: url);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showSnack('حدث خطأ، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text('إضافة رقية', style: AppTextStyles.heading(size: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'اسم الرقية',
                controller: _titleController,
                hint: 'مثلاً: رقية العين والحسد',
              ),

              const SizedBox(height: 22),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'نوع الرقية',
                  style: AppTextStyles.label(color: AppColors.ink, size: 13),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TypeChip(
                      label: 'يوتيوب',
                      icon: Icons.smart_display_outlined,
                      selected: _type == 'youtube',
                      onTap: () => setState(() => _type = 'youtube'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TypeChip(
                      label: 'ملف صوتي',
                      icon: Icons.music_note_outlined,
                      selected: _type == 'audio',
                      onTap: () => setState(() => _type = 'audio'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              if (_type == 'youtube') ...[
                AppTextField(
                  label: 'رابط اليوتيوب',
                  controller: _youtubeController,
                  hint: 'https://youtube.com/...',
                ),
              ] else ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الملف الصوتي',
                    style: AppTextStyles.label(color: AppColors.ink, size: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickAudioFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.parchment,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _pickedFileName != null
                              ? AppColors.teal.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.upload_file_outlined,
                            color: AppColors.teal,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _pickedFileName ?? 'اختيار ملف صوتي من الهاتف',
                              style: AppTextStyles.body(
                                color: _pickedFileName != null
                                    ? AppColors.ink
                                    : AppColors.inkFaint,
                                size: 13.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

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
                              'حفظ الرقية',
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

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.tealSoft : AppColors.parchment,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.teal : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.teal : AppColors.inkFaint),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.label(
                  color: selected ? AppColors.teal : AppColors.inkFaint,
                  size: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
