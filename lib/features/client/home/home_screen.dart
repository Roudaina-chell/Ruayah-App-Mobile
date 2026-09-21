import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenAppointments;

  const HomeScreen({super.key, required this.onOpenAppointments});

  @override
  Widget build(BuildContext context) {
    final appointmentService = AppointmentService();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'محمد الراقي',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'مرحبًا بك 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'نسأل الله أن يمنحك الشفاء والراحة',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.navy.withValues(alpha: 0.45),
              ),
            ),

            const SizedBox(height: 24),

            StreamBuilder<List<Appointment>>(
              stream: appointmentService.myAppointments(),
              builder: (context, snapshot) {
                final appointments = snapshot.data ?? [];
                final confirmed =
                    appointments.where((a) => a.status == 'confirmed').toList();
                final pending =
                    appointments.where((a) => a.status == 'pending').toList();
                final hasUnseen = appointments.any((a) =>
                    !a.seenByClient &&
                    (a.status == 'confirmed' || a.status == 'cancelled'));

                return _AppointmentsSummaryCard(
                  confirmedCount: confirmed.length,
                  pendingCount: pending.length,
                  nextConfirmed: confirmed.isNotEmpty ? confirmed.first : null,
                  hasUnseen: hasUnseen,
                  onTap: onOpenAppointments,
                );
              },
            ),

            const SizedBox(height: 24),

            _MenuTile(
              icon: Icons.menu_book_outlined,
              iconColor: const Color(0xFF00897B),
              title: 'برامج علاجية',
              subtitle: 'برامج متنوعة',
              onTap: () {},
            ),
            const SizedBox(height: 14),
            _MenuTile(
              icon: Icons.headphones_outlined,
              iconColor: const Color(0xFF7E57C2),
              title: 'رقيات مسموعة',
              subtitle: 'رقيات من القرآن والسنة',
              onTap: () {},
            ),
            const SizedBox(height: 14),
            _MenuTile(
              icon: Icons.chat_bubble_outline,
              iconColor: AppColors.primary,
              title: 'متابعة الحالات',
              subtitle: 'تواصل مع الراقي',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsSummaryCard extends StatelessWidget {
  final int confirmedCount;
  final int pendingCount;
  final Appointment? nextConfirmed;
  final bool hasUnseen;
  final VoidCallback onTap;

  const _AppointmentsSummaryCard({
    required this.confirmedCount,
    required this.pendingCount,
    required this.nextConfirmed,
    required this.hasUnseen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.veryLightBlue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.calendar_month_outlined,
                            color: AppColors.primary, size: 22),
                      ),
                      if (hasUnseen)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مواعيدي',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          confirmedCount == 0 && pendingCount == 0
                              ? 'لا توجد مواعيد بعد'
                              : '$confirmedCount مؤكد · $pendingCount قيد الانتظار',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.navy.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_back_ios_new,
                      size: 14, color: AppColors.navy.withValues(alpha: 0.3)),
                ],
              ),
              if (nextConfirmed != null) ...[
                const SizedBox(height: 12),
                Container(height: 1, color: AppColors.primary.withValues(alpha: 0.12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'موعدك القادم: ${nextConfirmed!.appointmentDate} الساعة ${nextConfirmed!.appointmentTime}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FB),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.navy.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new,
                size: 15,
                color: AppColors.navy.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}