import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/session_model.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/retro_scaffold.dart';

class MemberDetailScreen extends ConsumerWidget {
  final String memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(membersStreamProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return RetroScaffold(
      showBackButton: true,
      child: memberAsync.when(
        data: (members) {
          final member = members.firstWhere((m) => m.id == memberId, orElse: () => null as dynamic);
          if (member == null) {
            return Center(
              child: Text(
                'Member tidak ditemukan',
                style: GoogleFonts.tinos(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          final Color tierColor;
          final String tierName;
          final int nextTierPoints;
          final double progress;

          if (member.level == 'gold') {
            tierColor = AppColors.yellowSticker;
            tierName = 'GOLD';
            nextTierPoints = 0;
            progress = 1.0;
          } else if (member.level == 'silver') {
            tierColor = const Color(0xFFDCDCDC);
            tierName = 'SILVER';
            nextTierPoints = 2000;
            progress = member.points / 2000;
          } else {
            tierColor = AppColors.canvas;
            tierName = 'REGULAR';
            nextTierPoints = 500;
            progress = member.points / 500;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spec Sheet Eyebrow Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.tintSteel,
                      border: Border(
                        top: BorderSide(color: AppColors.frameInk),
                        left: BorderSide(color: AppColors.frameInk),
                        right: BorderSide(color: AppColors.frameInk),
                      ),
                    ),
                    child: Text(
                      'CUSTOMER SPECIFICATION SHEET / DETAIL MEMBER',
                      style: GoogleFonts.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Profile Info spec sheet table
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      border: Border.all(color: AppColors.frameInk),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow('NAMA LENGKAP / NAME', member.name),
                        _buildSpecRow('NOMOR TELEPON / PHONE', member.phone),
                        _buildSpecRow('TINGKATAN LEVEL / TIER', tierName, badgeColor: tierColor),
                        _buildSpecRow('DISCOUNT BENEFIT', '${(member.discountPercentage * 100).toInt()}% POTONGAN BERMAIN'),
                        _buildSpecRow('TOTAL SPENT / BELANJA', currencyFormatter.format(member.totalSpent)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Points Progress Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.tintSage,
                      border: Border(
                        top: BorderSide(color: AppColors.frameInk),
                        left: BorderSide(color: AppColors.frameInk),
                        right: BorderSide(color: AppColors.frameInk),
                      ),
                    ),
                    child: Text(
                      'LEVEL PROGRESSION / AKUMULASI POIN',
                      style: GoogleFonts.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      border: Border.all(color: AppColors.frameInk),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Poin Saat Ini / Current Points:',
                              style: GoogleFonts.tinos(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${member.points} pts',
                              style: GoogleFonts.arimo(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Retro flat progression bar
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            border: Border.all(color: AppColors.frameInk),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              color: AppColors.tintOlive,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (member.level != 'gold')
                          Text(
                            'Dibutuhkan ${nextTierPoints - member.points} poin tambahan untuk promosi level ke tingkatan ${member.level == 'regular' ? "SILVER" : "GOLD"}.',
                            style: GoogleFonts.tinos(color: AppColors.ink, fontSize: 12, fontStyle: FontStyle.italic),
                          )
                        else
                          Text(
                            'Selamat! Anggota telah mencapai tingkat level keanggotaan tertinggi.',
                            style: GoogleFonts.tinos(color: AppColors.ink, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Visited History Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.tintPeach,
                      border: Border(
                        top: BorderSide(color: AppColors.frameInk),
                        left: BorderSide(color: AppColors.frameInk),
                        right: BorderSide(color: AppColors.frameInk),
                      ),
                    ),
                    child: Text(
                      'VISITATION LOGS / RIWAYAT TRANSAKSI',
                      style: GoogleFonts.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('sessions')
                        .where('memberId', isEqualTo: memberId)
                        .where('status', isEqualTo: 'completed')
                        .orderBy('endTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.frameInk),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.frameInk),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'Belum ada riwayat transaksi.',
                              style: GoogleFonts.tinos(color: Colors.grey[600], fontSize: 13),
                            ),
                          ),
                        );
                      }

                      final sessions = snapshot.data!.docs
                          .map((doc) => SessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                          .toList();

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.frameInk),
                        ),
                        child: Column(
                          children: [
                            // Table headers
                            Container(
                              decoration: const BoxDecoration(
                                color: AppColors.tintSteel,
                                border: Border(
                                  bottom: BorderSide(color: AppColors.frameInk),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text('UNIT', style: GoogleFonts.arimo(fontSize: 10, fontWeight: FontWeight.bold))),
                                  Expanded(flex: 4, child: Text('TANGGAL', style: GoogleFonts.arimo(fontSize: 10, fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('DURASI', style: GoogleFonts.arimo(fontSize: 10, fontWeight: FontWeight.bold))),
                                  Expanded(flex: 3, child: Text('TOTAL', style: GoogleFonts.arimo(fontSize: 10, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sessions.length,
                              separatorBuilder: (context, index) => const Divider(color: AppColors.frameInk, height: 1),
                              itemBuilder: (context, index) {
                                final session = sessions[index];
                                final dateFormatted = session.endTime != null
                                    ? DateFormat('dd MMM yyyy, HH:mm').format(session.endTime!)
                                    : 'Selesai';
                                final Color rowBg = index.isEven ? AppColors.canvas : const Color(0xFFF9F9F9);

                                return Container(
                                  color: rowBg,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          session.unitName,
                                          style: GoogleFonts.tinos(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          dateFormatted,
                                          style: GoogleFonts.tinos(fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${session.durationMinutes ?? 0}m',
                                          style: GoogleFonts.tinos(fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          currencyFormatter.format(session.total),
                                          style: GoogleFonts.tinos(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(
          child: Text(
            'Error loading member: $e',
            style: GoogleFonts.tinos(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {Color? badgeColor}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.frameInk, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Left cell (label)
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFFF0F0F0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                label,
                style: GoogleFonts.arimo(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 36,
            color: AppColors.frameInk,
          ),
          // Right cell (value)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: badgeColor != null
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            border: Border.all(color: AppColors.frameInk),
                          ),
                          child: Text(
                            value,
                            style: GoogleFonts.arimo(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      value,
                      style: GoogleFonts.tinos(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
