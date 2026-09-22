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
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Hero header =====
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [AppColors.primary, AppColors.navy],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.4,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'محمد الراقي',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'مرحبًا بك',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'نسأل الله أن يمنحك الشفاء والراحة',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // subtle decorative accent — single considered flourish
                  Positioned(
                    top: -40,
                    left: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ===== Appointments summary — floats over the hero =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<List<Appointment>>(
                stream: appointmentService.myAppointments(),
                builder: (context, snapshot) {
                  final appointments = snapshot.data ?? [];
                  final confirmed = appointments
                      .where((a) => a.status == 'confirmed')
                      .toList();
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
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'خدماتنا',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MenuTile(
                    icon: Icons.menu_book_rounded,
                    accentColor: const Color(0xFF00897B),
                    title: 'برامج علاجية',
                    subtitle: 'برامج متنوعة',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _MenuTile(
                    icon: Icons.headphones_rounded,
                    accentColor: const Color(0xFF5E35B1),
                    title: 'رقيات مسموعة',
                    subtitle: 'رقيات من القرآن والسنة',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _MenuTile(
                    icon: Icons.chat_bubble_rounded,
                    accentColor: AppColors.primary,
                    title: 'متابعة الحالات',
                    subtitle: 'تواصل مع الراقي',
                    onTap: () {},
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
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.navy.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
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
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.veryLightBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.calendar_month_rounded,
                            color: AppColors.primary, size: 22),
                      ),
                      if (hasUnseen)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مواعيدي',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            letterSpacing: -0.2,
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
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.navy.withValues(alpha: 0.25)),
                ],
              ),
              if (nextConfirmed != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.veryLightBlue.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'موعدك القادم: ${nextConfirmed!.appointmentDate} الساعة ${nextConfirmed!.appointmentTime}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
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
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.navy.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 22),
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
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                        letterSpacing: -0.2,
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
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.navy.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}