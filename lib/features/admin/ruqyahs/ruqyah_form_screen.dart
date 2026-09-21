import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$_pickedFileName';
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        title: Text(
          'إضافة رقية',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('اسم الرقية'),
              const SizedBox(height: 8),
              _buildTextField(_titleController, 'مثلاً: رقية العين والحسد'),

              const SizedBox(height: 22),

              _buildLabel('نوع الرقية'),
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
                _buildLabel('رابط اليوتيوب'),
                const SizedBox(height: 8),
                _buildTextField(_youtubeController, 'https://youtube.com/...'),
              ] else ...[
                _buildLabel('الملف الصوتي'),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickAudioFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.upload_file_outlined, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _pickedFileName ?? 'اختيار ملف صوتي من الهاتف',
                              style: TextStyle(
                                color: _pickedFileName != null
                                    ? AppColors.navy
                                    : AppColors.navy.withValues(alpha: 0.4),
                                fontSize: 13.5,
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

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      : const Text('حفظ الرقية',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      child: Text(text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F8FC), borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
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
            color: selected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF5F8FC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.navy.withValues(alpha: 0.4)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.navy.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}