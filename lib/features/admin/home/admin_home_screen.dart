import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_screen.dart';

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
      backgroundColor: AppColors.white,
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
                          color: const Color(0xFFF5F8FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.menu, color: AppColors.ink, size: 20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'لوحة الإدارة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // بطاقة الترحيب الرئيسية — Gradient
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.teal, const Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبًا بك، محمد الراقي',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إليك ملخص نشاط التطبيق اليوم',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Stat cards — صف أفقي قابل للتمرير
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
                              final usersCount =
                                  usersSnap.data?.docs.length ?? 0;
                              final programsCount =
                                  programsSnap.data?.docs.length ?? 0;
                              final ruqyahsCount =
                                  ruqyahsSnap.data?.docs.length ?? 0;
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
                                    color: const Color(0xFF43A047),
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
                                    color: const Color(0xFF8E24AA),
                                    count: ruqyahsCount,
                                    label: 'الرقيات المسموعة',
                                  ),
                                  _StatCard(
                                    icon: Icons.calendar_month_rounded,
                                    color: const Color(0xFFFB8C00),
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

              const SizedBox(height: 28),

              Row(
                children: [
                  Text(
                    'أحدث الطلبات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onOpenAppointments,
                    child: Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                      child: Center(
                        child:
                            CircularProgressIndicator(color: AppColors.teal),
                      ),
                    );
                  }

                  final appointments = (snapshot.data ?? []).take(4).toList();

                  if (appointments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'لا توجد طلبات حتى الآن.',
                          style: TextStyle(
                            color: AppColors.ink.withValues(alpha: 0.4),
                            fontSize: 13,
                          ),
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
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: highlight
                  ? color.withValues(alpha: 0.4)
                  : AppColors.ink.withValues(alpha: 0.06),
              width: highlight ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.ink.withValues(alpha: 0.5),
                ),
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
        return {
          'label': 'مؤكد',
          'color': const Color(0xFF43A047),
          'bg': const Color(0xFFE8F5E9),
        };
      case 'cancelled':
        return {
          'label': 'ملغى',
          'color': const Color(0xFFE53935),
          'bg': const Color(0xFFFFEBEE),
        };
      default:
        return {
          'label': 'معلق',
          'color': const Color(0xFFFB8C00),
          'bg': const Color(0xFFFFF3E0),
        };
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get _initial =>
      appointment.userName.isNotEmpty ? appointment.userName[0] : '؟';

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initial,
                style: TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.userPhone,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status['bg'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status['label'],
                  style: TextStyle(
                    color: status['color'],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(appointment.createdAt),
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.ink.withValues(alpha: 0.4),
                ),
              ),
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
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: AppColors.ink),
              title: Text('الملف الشخصي', style: TextStyle(color: AppColors.ink)),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFE53935)),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Color(0xFFE53935))),
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