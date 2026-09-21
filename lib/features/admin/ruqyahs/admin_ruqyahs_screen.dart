import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/ruqyah.dart';
import '../../../services/ruqyah_service.dart';
import 'ruqyah_form_screen.dart';

class AdminRuqyahsScreen extends StatelessWidget {
  const AdminRuqyahsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = RuqyahService();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        title: Text(
          'إدارة الرقيات المسموعة',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RuqyahFormScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Ruqyah>>(
          stream: service.allRuqyahs(),
          builder: (context, snapshot) {
            final ruqyahs = snapshot.data ?? [];

            if (ruqyahs.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد رقيات بعد. اضغط + لإضافة رقية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 14),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: ruqyahs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ruqyah = ruqyahs[index];
                return _AdminRuqyahTile(ruqyah: ruqyah, service: service);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdminRuqyahTile extends StatelessWidget {
  final Ruqyah ruqyah;
  final RuqyahService service;

  const _AdminRuqyahTile({required this.ruqyah, required this.service});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرقية'),
        content: Text('هل أنت متأكد من حذف "${ruqyah.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await service.deleteRuqyah(ruqyah.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isYoutube = ruqyah.type == 'youtube';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isYoutube ? Icons.smart_display_outlined : Icons.music_note_outlined,
            color: const Color(0xFF7E57C2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ruqyah.title,
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.navy),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 20),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}