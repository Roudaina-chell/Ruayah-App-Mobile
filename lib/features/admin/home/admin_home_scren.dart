import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/geometric_pattern.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_screen.dart';
import '../profile/admin_profile_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final VoidCallback onOpenPrograms;
  final VoidCallback onOpenAppointments;

  const AdminHomeScreen({
    super.key,
    required this.onOpenPrograms,
    required this.onOpenAppointments,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final appointmentService = AppointmentService();

    return Scaffold(
      backgroundColor: AppColors.parchment,
      drawer: _AdminDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar بسيط
              Row(
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.teal.withValues(alpha: 0.08)),
                        ),
                        child: const Icon(Icons.menu, color: AppColors.ink, size: 20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text('لوحة الإدارة', style: AppTextStyles.heading(size: 15)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.15)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // بطاقة الترحيب الرئيسية
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const GeometricPatternBackground(color: Colors.white, opacity: 0.07),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مرحبًا بك، محمد الراقي', style: AppTextStyles.displaySmall(color: Colors.white, size: 19)),
                          const SizedBox(height: 5),
                          Text(
                            'إليك ملخص نشاط التطبيق اليوم',
                            style: AppTextStyles.body(color: Colors.white.withValues(alpha: 0.82), size: 12.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Stat cards
              StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('users')
                    .where('role', isEqualTo: 'client')
                    .snapshots(),
                builder: (context, usersSnap) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection('programs').snapshots(),
                    builder: (context, programsSnap) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: firestore.collection('ruqyahs').snapshots(),
                        builder: (context, ruqyahsSnap) {
                          return StreamBuilder<List<Appointment>>(
                            stream: appointmentService.allAppointments(),
                            builder: (context, apptSnap) {
                              final usersCount = usersSnap.data?.docs.length ?? 0;
                              final programsCount = programsSnap.data?.docs.length ?? 0;
                              final ruqyahsCount = ruqyahsSnap.data?.docs.length ?? 0;
                              final pendingCount = (apptSnap.data ?? [])
                                  .where((a) => a.status == 'pending')
                                  .length;

                              return GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.35,
                                children: [
                                  _StatCard(
                                    icon: Icons.people_alt_rounded,
                                    color: AppColors.success,
                                    count: usersCount,
                                    label: 'إجمالي المستخدمين',
                                  ),
                                  _StatCard(
                                    icon: Icons.menu_book_rounded,
                                    color: AppColors.teal,
                                    count: programsCount,
                                    label: 'البرامج العلاجية',
                                    onTap: onOpenPrograms,
                                  ),
                                  _StatCard(
                                    icon: Icons.headphones_rounded,
                                    color: AppColors.plum,
                                    count: ruqyahsCount,
                                    label: 'الرقيات المسموعة',
                                  ),
                                  _StatCard(
                                    icon: Icons.calendar_month_rounded,
                                    color: AppColors.pending,
                                    count: pendingCount,
                                    label: 'طلبات الحجز المعلقة',
                                    onTap: onOpenAppointments,
                                    highlight: pendingCount > 0,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Text('أحدث الطلبات', style: AppTextStyles.heading(size: 16)),
                  const Spacer(),
                  GestureDetector(
                    onTap: onOpenAppointments,
                    child: Text('عرض الكل', style: AppTextStyles.label(color: AppColors.goldDeep, size: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              StreamBuilder<List<Appointment>>(
                stream: appointmentService.allAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
                    );
                  }

                  final appointments = (snapshot.data ?? []).take(4).toList();

                  if (appointments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'لا توجد طلبات حتى الآن.',
                          style: AppTextStyles.body(color: AppColors.inkFaint, size: 13),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: appointments
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _RecentRequestTile(appointment: a),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final String label;
  final VoidCallback? onTap;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withValues(alpha: 0.1),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: highlight ? color.withValues(alpha: 0.45) : AppColors.teal.withValues(alpha: 0.07),
              width: highlight ? 1.4 : 1,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text('$count', style: AppTextStyles.heading(size: 24)),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardSubtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRequestTile extends StatelessWidget {
  final Appointment appointment;

  const _RecentRequestTile({required this.appointment});

  Map<String, dynamic> get _statusInfo {
    switch (appointment.status) {
      case 'confirmed':
        return {'label': 'مؤكد', 'color': AppColors.success, 'bg': AppColors.successSoft};
      case 'cancelled':
        return {'label': 'ملغى', 'color': AppColors.danger, 'bg': AppColors.dangerSoft};
      default:
        return {'label': 'معلق', 'color': AppColors.pending, 'bg': AppColors.pendingSoft};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get _initial => appointment.userName.isNotEmpty ? appointment.userName[0] : '؟';

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: AppColors.tealSoft, shape: BoxShape.circle),
            child: Center(
              child: Text(_initial, style: AppTextStyles.heading(color: AppColors.teal, size: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.userName, style: AppTextStyles.cardTitle),
                const SizedBox(height: 2),
                Text(appointment.userPhone, style: AppTextStyles.cardSubtitle),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: status['bg'], borderRadius: BorderRadius.circular(8)),
                child: Text(
                  status['label'],
                  style: AppTextStyles.label(color: status['color'], size: 11).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 6),
              Text(_formatDate(appointment.createdAt), style: AppTextStyles.label(color: AppColors.inkFaint, size: 10.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.parchment,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.15)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: AppColors.ink),
              title: Text('الملف الشخصي', style: AppTextStyles.body(size: 14.5)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: Text('تسجيل الخروج', style: AppTextStyles.body(color: AppColors.danger, size: 14.5)),
              onTap: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}