import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'home/home_screen.dart';
import 'appointments/appointments_screen.dart';
import 'programs/programs_screen.dart';
import 'ruqyahs/ruqyahs_screen.dart';
import 'cases/cases_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final AppointmentService _appointmentService = AppointmentService();

  late final List<Widget> _pages = [
    HomeScreen(
      onOpenAppointments: () => setState(() => _currentIndex = 3),
    ),
    const ProgramsScreen(),
    const RuqyahsScreen(),
    const AppointmentsScreen(),
    const CasesScreen(),
  ];

  final List<String> _titles = const [
    'محمد الراقي',
    'البرامج العلاجية',
    'الرقيات المسموعة',
    'حجز المواعيد',
    'متابعة الحالات',
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'البرامج'),
    _NavItem(icon: Icons.headphones_rounded, label: 'الرقيات'),
    _NavItem(icon: Icons.calendar_today_rounded, label: 'المواعيد'),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'الحالات'),
  ];

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      extendBody: true,
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              backgroundColor: AppColors.parchment,
              elevation: 0,
              centerTitle: true,
              title: Text(
                _titles[_currentIndex],
                style: AppTextStyles.heading(size: 17),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded, color: AppColors.ink),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.ink),
                  onPressed: _logout,
                ),
              ],
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: StreamBuilder<List<Appointment>>(
        stream: _appointmentService.myAppointments(),
        builder: (context, snapshot) {
          final appointments = snapshot.data ?? [];
          final hasUnseenUpdate = appointments.any((a) =>
              !a.seenByClient &&
              (a.status == 'confirmed' || a.status == 'cancelled'));

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tealDeep.withValues(alpha: 0.1),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_navItems.length, (index) {
                    final isSelected = index == _currentIndex;
                    final showBadge = index == 3 && hasUnseenUpdate;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _currentIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.tealSoft
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    _navItems[index].icon,
                                    color: isSelected
                                        ? AppColors.teal
                                        : AppColors.inkFaint,
                                    size: 22,
                                  ),
                                  if (showBadge)
                                    Positioned(
                                      top: -3,
                                      right: -6,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.gold,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.surface, width: 1.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 240),
                                style: AppTextStyles.label(
                                  color: isSelected
                                      ? AppColors.teal
                                      : AppColors.inkFaint,
                                  size: 10.5,
                                ),
                                child: Text(_navItems[index].label),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}