import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'member/member_list_screen.dart';
import 'report/report_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (profile) {
        final isOwner = profile?.role == 'owner';

        // Define tabs list dynamically based on role
        final List<Widget> screens = [
          const DashboardScreen(),
          const MemberListScreen(),
          if (isOwner) const ReportScreen(),
          if (isOwner) const SettingsScreen(),
        ];

        final List<BottomNavigationBarItem> navItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Member',
          ),
          if (isOwner)
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Laporan',
            ),
          if (isOwner)
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
        ];

        // Guard against index out of range (if shifting from owner to operator)
        if (_currentIndex >= screens.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x26FFFFFF), width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: const Color(0xFF12121A),
              selectedItemColor: const Color(0xFF0088FF),
              unselectedItemColor: Colors.white38,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: navItems,
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, __) => Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan: $e',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userProfileProvider);
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
