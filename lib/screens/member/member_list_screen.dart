import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/member_model.dart';
import '../../providers/services_provider.dart';

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
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: const Text(
          'DAFTAR MEMBER',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau nomor handphone...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0088FF)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF12121A),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0088FF)),
                ),
              ),
            ),
          ),

          // Member List
          Expanded(
            child: membersAsync.when(
              data: (members) {
                // Filter members in memory
                final filtered = members.where((m) {
                  return m.name.toLowerCase().contains(_searchQuery) ||
                      m.phone.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'Belum ada member terdaftar.' : 'Member tidak ditemukan.',
                      style: const TextStyle(color: Colors.white38),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final member = filtered[index];
                    return _MemberTile(member: member);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(
                child: Text('Gagal memuat data: $e', style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-member');
        },
        backgroundColor: const Color(0xFF0088FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _MemberTile extends StatelessWidget {
  final MemberModel member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    // Styling attributes based on member level
    final Color tierColor;
    final String tierName;

    if (member.level == 'gold') {
      tierColor = const Color(0xFFFFD700); // Gold
      tierName = 'GOLD';
    } else if (member.level == 'silver') {
      tierColor = const Color(0xFFC0C0C0); // Silver
      tierName = 'SILVER';
    } else {
      tierColor = const Color(0xFF0088FF); // Blue / Regular
      tierName = 'REGULAR';
    }

    // Generate Initials
    final words = member.name.trim().split(' ');
    final initials = words.length > 1
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : words[0].isNotEmpty
            ? words[0][0].toUpperCase()
            : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          context.push('/member-detail/${member.id}');
        },
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: tierColor.withOpacity(0.4), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: tierColor.withOpacity(0.15),
            child: Text(
              initials,
              style: TextStyle(
                color: tierColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: tierColor.withOpacity(0.3), width: 0.8),
              ),
              child: Text(
                tierName,
                style: TextStyle(
                  color: tierColor,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            member.phone,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${member.points} pts',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${member.totalVisits} Kunjungan',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
