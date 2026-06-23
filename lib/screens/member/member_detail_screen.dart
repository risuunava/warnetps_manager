import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/member_model.dart';
import '../../models/session_model.dart';
import '../../providers/services_provider.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('PROFIL MEMBER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: memberAsync.when(
        data: (members) {
          final member = members.firstWhere((m) => m.id == memberId, orElse: () => null as dynamic);
          if (member == null) {
            return const Center(child: Text('Member tidak ditemukan', style: TextStyle(color: Colors.redAccent)));
          }

          // Level styling properties
          final Color tierColor;
          final String tierName;
          final int nextTierPoints;
          final double progress;

          if (member.level == 'gold') {
            tierColor = const Color(0xFFFFD700);
            tierName = 'GOLD';
            nextTierPoints = 0;
            progress = 1.0;
          } else if (member.level == 'silver') {
            tierColor = const Color(0xFFC0C0C0);
            tierName = 'SILVER';
            nextTierPoints = 2000;
            progress = member.points / 2000;
          } else {
            tierColor = const Color(0xFF0088FF);
            tierName = 'REGULAR';
            nextTierPoints = 500;
            progress = member.points / 500;
          }

          // Generate Initials
          final words = member.name.trim().split(' ');
          final initials = words.length > 1
              ? '${words[0][0]}${words[1][0]}'.toUpperCase()
              : words[0].isNotEmpty
                  ? words[0][0].toUpperCase()
                  : '?';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: tierColor.withOpacity(0.4), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: tierColor.withOpacity(0.15),
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: tierColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          member.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member.phone,
                          style: const TextStyle(fontSize: 13, color: Colors.white38),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: tierColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: tierColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            tierName,
                            style: TextStyle(
                              color: tierColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Points Progress card
                  const Text('PROGRES LEVEL & AKUMULASI POIN', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Poin Tersedia', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Text('${member.points} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress > 1.0 ? 1.0 : progress,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (member.level != 'gold')
                          Text(
                            'Butuh ${nextTierPoints - member.points} poin lagi untuk naik ke level ${member.level == 'regular' ? "SILVER" : "GOLD"}',
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          )
                        else
                          const Text(
                            'Selamat! Anda berada di tingkatan level tertinggi.',
                            style: TextStyle(color: Color(0xFF00C853), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 16),
                        // Benefits summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diskon Bermain', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Text(
                              '${(member.discountPercentage * 100).toInt()}% Potongan Otomatis',
                              style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Transaksi', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Text(currencyFormatter.format(member.totalSpent), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction History list
                  const Text('RIWAYAT KUNJUNGAN & TRANSAKSI', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('sessions')
                        .where('memberId', isEqualTo: memberId)
                        .where('status', isEqualTo: 'completed')
                        .orderBy('endTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Center(child: Text('Belum ada riwayat transaksi.', style: TextStyle(color: Colors.white38, fontSize: 13))),
                        );
                      }

                      final sessions = snapshot.data!.docs.map((doc) => SessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sessions.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.white24, height: 1),
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            final dateFormatted = session.endTime != null
                                ? DateFormat('dd MMM yyyy, HH:mm').format(session.endTime!)
                                : 'Selesai';

                            return ListTile(
                              title: Text(session.unitName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(dateFormatted, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormatter.format(session.total),
                                    style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${session.durationMinutes ?? 0}m',
                                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error loading member: $e', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}
