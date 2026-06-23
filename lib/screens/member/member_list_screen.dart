import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/retro_bevel_container.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow label
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
                'CUSTOMER DATABASE / ARSIP MEMBER',
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
            const SizedBox(height: 12),

            // Search box
            TextField(
              controller: _searchController,
              style: GoogleFonts.tinos(color: AppColors.ink),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau nomor telepon...',
                prefixIcon: const Icon(Icons.search, color: AppColors.ink, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppColors.ink, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // HTML-style Table Header
            Container(
              decoration: const BoxDecoration(
                color: AppColors.tintSteel,
                border: Border(
                  top: BorderSide(color: AppColors.frameInk),
                  left: BorderSide(color: AppColors.frameInk),
                  right: BorderSide(color: AppColors.frameInk),
                  bottom: BorderSide(color: AppColors.frameInk, width: 2),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'NAMA MEMBER',
                      style: GoogleFonts.arimo(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'LEVEL',
                      style: GoogleFonts.arimo(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'POIN',
                      style: GoogleFonts.arimo(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'KUNJUNGAN',
                      style: GoogleFonts.arimo(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Member list content
            Expanded(
              child: membersAsync.when(
                data: (members) {
                  final filtered = members.where((m) {
                    return m.name.toLowerCase().contains(_searchQuery) ||
                        m.phone.contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.frameInk),
                          right: BorderSide(color: AppColors.frameInk),
                          bottom: BorderSide(color: AppColors.frameInk),
                        ),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, color: AppColors.ink, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada member terdaftar.'
                                : 'Member tidak ditemukan.',
                            style: GoogleFonts.tinos(
                              fontSize: 14,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      final Color rowBg = index.isEven ? AppColors.canvas : const Color(0xFFF9F9F9);

                      return InkWell(
                        onTap: () {
                          context.push('/member-detail/${member.id}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: rowBg,
                            border: const Border(
                              left: BorderSide(color: AppColors.frameInk),
                              right: BorderSide(color: AppColors.frameInk),
                              bottom: BorderSide(color: AppColors.frameInk),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              // Name & Phone
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: GoogleFonts.tinos(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member.phone,
                                      style: GoogleFonts.tinos(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Level Badge
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: member.level == 'gold'
                                          ? AppColors.yellowSticker
                                          : (member.level == 'silver'
                                              ? const Color(0xFFDCDCDC)
                                              : AppColors.canvas),
                                      border: Border.all(color: AppColors.frameInk),
                                    ),
                                    child: Text(
                                      member.level.toUpperCase(),
                                      style: GoogleFonts.arimo(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Points
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${member.points} pts',
                                  style: GoogleFonts.tinos(
                                    fontSize: 13,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),

                              // Visits
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${member.totalVisits} x',
                                  style: GoogleFonts.tinos(
                                    fontSize: 13,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Gagal memuat data: $e',
                      style: GoogleFonts.tinos(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: RetroBevelContainer(
        color: AppColors.yellowSticker,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            context.push('/add-member');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.frameInk, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: AppColors.ink, size: 16),
                const SizedBox(width: 6),
                Text(
                  'TAMBAH MEMBER',
                  style: GoogleFonts.arimo(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
