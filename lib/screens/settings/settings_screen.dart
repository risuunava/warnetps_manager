import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: const Text(
          'PENGATURAN OWNER',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0088FF), width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF0088FF).withOpacity(0.15),
                        child: const Icon(Icons.person, color: Color(0xFF0088FF), size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile?.name ?? 'Nama Owner',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userProfile?.email ?? 'email@owner.com',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0088FF).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'OWNER',
                              style: TextStyle(
                                color: Color(0xFF00D4FF),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'MANAJEMEN OUTLET',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Settings Menu options
              _buildMenuTile(
                icon: Icons.payments_outlined,
                title: 'Kelola Tarif Sesi',
                subtitle: 'Ubah tarif PC standar, PS4, PS3, dan PS2',
                color: const Color(0xFF0088FF),
                onTap: () {
                  context.push('/manage-tariffs');
                },
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.people_outline,
                title: 'Kelola Operator',
                subtitle: 'Tambah/nonaktifkan akun operator kasir',
                color: const Color(0xFF00D4FF),
                onTap: () {
                  context.push('/manage-operators');
                },
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.storefront_outlined,
                title: 'Informasi Toko',
                subtitle: 'Nama warnet, alamat, nomor telepon',
                color: const Color(0xFF00C853),
                onTap: () {
                  _showShopInfoDialog(context);
                },
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleLogout(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'KELUAR AKUN',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  void _showShopInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF12121A),
          title: const Text('Info Toko (MVP)', style: TextStyle(color: Colors.white)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Toko: WarnetPS Manager Outlet 1', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('Alamat: Jl. Raya Cyber No. 404, Jakarta', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('Kontak: 0812-3456-7890', style: TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(color: Color(0xFF0088FF))),
            ),
          ],
        );
      },
    );
  }
}
