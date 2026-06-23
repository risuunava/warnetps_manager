import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/shared/retro_scaffold.dart';
import '../widgets/shared/solid_bottom_navigation_bar.dart';
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

        final List<BottomNavItem> navItems = [
          BottomNavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
          ),
          BottomNavItem(
            icon: Icons.group,
            label: 'Member',
          ),
          if (isOwner)
            BottomNavItem(
              icon: Icons.assessment,
              label: 'Laporan',
            ),
          if (isOwner)
            BottomNavItem(
              icon: Icons.settings,
              label: 'Pengaturan',
            ),
        ];

        // Guard against index out of range (if shifting from owner to operator)
        if (_currentIndex >= screens.length) {
          _currentIndex = 0;
        }

        return RetroScaffold(
          bottomNavigationBar: SolidBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: navItems,
          ),
          child: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, __) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan: $e',
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
