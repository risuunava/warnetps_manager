import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Eyebrow
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.tintOlive,
                    border: Border(
                      top: BorderSide(color: AppColors.frameInk),
                      left: BorderSide(color: AppColors.frameInk),
                      right: BorderSide(color: AppColors.frameInk),
                    ),
                  ),
                  child: Text(
                    'OPERATIONAL SETTINGS / PENGATURAN OUTLET',
                    style: GoogleFonts.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.frameInk,
                ),
                const SizedBox(height: 16),

                // Profile Header Section
                _buildProfileHeader(context, userProfile),
                const SizedBox(height: 24),

                // Group: Manajemen Outlet
                _buildSectionTitle(context, 'MANAJEMEN OUTLET / SYSTEM MANAGEMENT'),
                const SizedBox(height: 8),
                _buildMenuGroup(context, [
                  _MenuItemData(
                    icon: Icons.payments,
                    label: 'Tarif & Paket Sewa',
                    onTap: () => context.push('/manage-tariffs'),
                    hasBorder: true,
                  ),
                  _MenuItemData(
                    icon: Icons.manage_accounts,
                    label: 'Daftar & Manajemen Operator',
                    onTap: () => context.push('/manage-operators'),
                    hasBorder: true,
                  ),
                  _MenuItemData(
                    icon: Icons.store,
                    label: 'Informasi Cabang / Toko',
                    onTap: () => _showShopInfoDialog(context),
                    hasBorder: false,
                  ),
                ]),
                const SizedBox(height: 24),

                // Group: Sistem
                _buildSectionTitle(context, 'SISTEM KONTROL / SECURITIES'),
                const SizedBox(height: 8),
                _buildMenuGroup(context, [
                  _MenuItemData(
                    icon: Icons.logout,
                    label: 'Keluar Dari Akun (Log Out)',
                    isDestructive: true,
                    onTap: () => _handleLogout(context, ref),
                    hasBorder: false,
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic userProfile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.frameInk),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Square Avatar Frame
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.tintSteel,
              border: Border.all(color: AppColors.frameInk, width: 1.0),
            ),
            child: const Icon(Icons.person, color: AppColors.ink, size: 36),
          ),
          const SizedBox(width: 16),

          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile?.name ?? 'OPERATOR UTAMA',
                  style: GoogleFonts.tinos(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.yellowSticker,
                    border: Border.all(color: AppColors.frameInk),
                  ),
                  child: Text(
                    (userProfile?.role ?? 'OWNER').toUpperCase(),
                    style: GoogleFonts.arimo(
                      color: AppColors.ink,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.arimo(
          color: AppColors.ink,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.frameInk),
      ),
      child: Column(
        children: items.map((item) => _buildMenuItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItemData item) {
    final Color textColor = item.isDestructive ? AppColors.primary : AppColors.ink;
    final Color iconColor = item.isDestructive ? AppColors.primary : AppColors.ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: item.hasBorder
                ? const Border(
                    bottom: BorderSide(color: AppColors.frameInk),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    item.icon,
                    color: iconColor,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: GoogleFonts.tinos(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (!item.isDestructive)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.ink,
                  size: 12,
                ),
            ],
          ),
        ),
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
          backgroundColor: AppColors.canvas,
          shape: const Border(
            top: BorderSide(color: AppColors.frameInk, width: 4.0),
            left: BorderSide(color: AppColors.frameInk, width: 2.0),
            right: BorderSide(color: AppColors.frameInk, width: 2.0),
            bottom: BorderSide(color: AppColors.frameInk, width: 2.0),
          ),
          title: Text(
            'SHOP DETAIL / INFORMASI OUTLET',
            style: GoogleFonts.arimo(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Toko: WarnetPS Manager V3.0',
                style: GoogleFonts.tinos(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Alamat: Jl. Raya Cyber No. 404, Jakarta',
                style: GoogleFonts.tinos(color: AppColors.ink, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Kontak Hotline: 1-800-213-DELL',
                style: GoogleFonts.tinos(color: AppColors.ink, fontSize: 13),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.frameInk,
                  border: Border.all(color: AppColors.frameInk),
                ),
                child: Text(
                  'TUTUP DIALOG',
                  style: GoogleFonts.arimo(
                    color: AppColors.canvas,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hasBorder;
  final bool isDestructive;

  _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.hasBorder,
    this.isDestructive = false,
  });
}
