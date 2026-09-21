import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home/admin_home_screen.dart';
import 'programs/admin_programs_screen.dart';
import 'appointments/admin_appointments_screen.dart';
import 'ruqyahs/admin_ruqyahs_screen.dart';

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
    const _PlaceholderTab(message: 'لا توجد حالات أو رسائل جديدة.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _goToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.navy.withValues(alpha: 0.4),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'البرامج',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones_outlined),
            activeIcon: Icon(Icons.headphones),
            label: 'الرقيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'الحالات',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String message;
  const _PlaceholderTab({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}