import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/retro_scaffold.dart';
import '../../widgets/shared/retro_bevel_container.dart';

class ManageOperatorsScreen extends ConsumerWidget {
  const ManageOperatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RetroScaffold(
      showBackButton: true,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'operator')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final operators = snapshot.hasData ? snapshot.data!.docs : [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Eyebrow
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
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
                        'OPERATOR ACCOUNTS / MANAJEMEN OPERATOR',
                        style: GoogleFonts.arimo(
                          fontSize: 12,
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
                  ],
                ),
              ),

              // Notice Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tintSky,
                  border: Border.all(color: AppColors.frameInk, width: 1.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info, color: AppColors.ink, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PENTING: Setelah menambahkan operator di sini, pastikan untuk mendaftarkan Email dan Password tersebut di Firebase Console > Authentication agar operator dapat login.',
                        style: GoogleFonts.tinos(
                          color: AppColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Operator Database List
              Expanded(
                child: operators.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'Belum ada operator terdaftar. Tambah data operator untuk memberikan akses masuk.',
                            style: GoogleFonts.tinos(color: Colors.grey[600], fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: operators.length,
                        itemBuilder: (context, index) {
                          final data = operators[index].data() as Map<String, dynamic>;
                          final docId = operators[index].id;
                          final name = data['name'] ?? 'No Name';
                          final email = data['email'] ?? 'No Email';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              border: Border.all(color: AppColors.frameInk, width: 1.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.tintSteel,
                                  border: Border.all(color: AppColors.frameInk),
                                ),
                                child: const Icon(Icons.person, color: AppColors.ink, size: 20),
                              ),
                              title: Text(
                                name,
                                style: GoogleFonts.tinos(fontWeight: FontWeight.bold, color: AppColors.ink),
                              ),
                              subtitle: Text(
                                email,
                                style: GoogleFonts.tinos(fontSize: 12, color: Colors.grey[700]),
                              ),
                              trailing: GestureDetector(
                                onTap: () => _showDeleteConfirmation(context, docId, name),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvas,
                                    border: Border.all(color: AppColors.primary),
                                  ),
                                  child: const Icon(
                                    Icons.delete_forever,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: RetroBevelContainer(
        color: AppColors.yellowSticker,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => _showAddOperatorDialog(context),
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
                  'TAMBAH OPERATOR',
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

  void _showAddOperatorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final uidController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
            'DAFTAR OPERATOR BARU / REGISTRATION',
            style: GoogleFonts.arimo(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama Operator:', style: GoogleFonts.tinos(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: nameController,
                    style: GoogleFonts.tinos(),
                    decoration: const InputDecoration(hintText: 'e.g. Andi Wijaya'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Email Operator:', style: GoogleFonts.tinos(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: emailController,
                    style: GoogleFonts.tinos(),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'e.g. andi@cybernet.com'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                      if (!value.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('UID Firebase (dari Console):', style: GoogleFonts.tinos(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: uidController,
                    style: GoogleFonts.tinos(),
                    decoration: const InputDecoration(
                      hintText: 'UID unik dari Authentication Console',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'UID Firebase wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tempel UID hasil pembuatan user di Firebase Console Auth.',
                    style: GoogleFonts.tinos(fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.frameInk),
                ),
                child: Text(
                  'BATAL',
                  style: GoogleFonts.arimo(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                if (formKey.currentState!.validate()) {
                  final db = FirebaseFirestore.instance;
                  await db.collection('users').doc(uidController.text.trim()).set({
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'role': 'operator',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Data operator berhasil ditambahkan',
                          style: GoogleFonts.tinos(),
                        ),
                        backgroundColor: AppColors.tintSage,
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.frameInk,
                  border: Border.all(color: AppColors.frameInk),
                ),
                child: Text(
                  'SIMPAN OPERATOR',
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

  void _showDeleteConfirmation(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.canvas,
          shape: const Border(
            top: BorderSide(color: AppColors.primary, width: 4.0),
            left: BorderSide(color: AppColors.frameInk, width: 2.0),
            right: BorderSide(color: AppColors.frameInk, width: 2.0),
            bottom: BorderSide(color: AppColors.frameInk, width: 2.0),
          ),
          title: Text(
            'DELETE OPERATOR / HAPUS AKSES',
            style: GoogleFonts.arimo(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus akses untuk operator $name? Operator tidak akan bisa mengakses dashboard lagi.',
            style: GoogleFonts.tinos(),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.frameInk),
                ),
                child: Text(
                  'BATAL',
                  style: GoogleFonts.arimo(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await FirebaseFirestore.instance.collection('users').doc(docId).delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Akses operator $name telah dihapus',
                        style: GoogleFonts.tinos(),
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.frameInk),
                ),
                child: Text(
                  'HAPUS OPERATOR',
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
