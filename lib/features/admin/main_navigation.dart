import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'home/admin_home_screen.dart';
import 'programs/admin_programs_screen.dart';
import 'ruqyahs/admin_ruqyahs_screen.dart';
import 'appointments/admin_appointments_screen.dart';
import 'cases/admin_cases_screen.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _currentIndex = 0;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  late final List<Widget> _pages = [
    AdminHomeScreen(
      onOpenPrograms: () => _goToTab(1),
      onOpenAppointments: () => _goToTab(3),
    ),
    const AdminProgramsScreen(),
    const AdminRuqyahsScreen(),
    const AdminAppointmentsScreen(),
    const AdminCasesScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'البرامج'),
    _NavItem(icon: Icons.headphones_rounded, label: 'الرقيات'),
    _NavItem(icon: Icons.calendar_today_rounded, label: 'المواعيد'),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'الحالات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
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
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _goToTab(index),
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
                          Icon(
                            _navItems[index].icon,
                            color: isSelected
                                ? AppColors.teal
                                : AppColors.inkFaint,
                            size: 22,
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
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
