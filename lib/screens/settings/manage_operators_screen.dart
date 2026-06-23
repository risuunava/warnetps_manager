import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOperatorsScreen extends ConsumerWidget {
  const ManageOperatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('KELOLA AKUN OPERATOR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'operator')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Belum ada operator terdaftar. Tambah data operator untuk memberikan akses masuk.',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final operators = snapshot.data!.docs;

          return Column(
            children: [
              // Notice info banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0088FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0088FF).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF00D4FF), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PENTING: Setelah menambahkan operator di sini, pastikan untuk mendaftarkan Email dan Password tersebut di Firebase Console > Authentication.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              // Operators List
              Expanded(
                child: ListView.builder(
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
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: const Icon(Icons.person, color: Colors.white70),
                        ),
                        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            _showDeleteConfirmation(context, docId, name);
                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOperatorDialog(context),
        backgroundColor: const Color(0xFF0088FF),
        child: const Icon(Icons.add, color: Colors.white),
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
          backgroundColor: const Color(0xFF12121A),
          title: const Text('Tambah Operator Baru', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nama Operator',
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Operator',
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                      if (!value.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: uidController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'UID Firebase (dari Auth Console)',
                      labelStyle: TextStyle(color: Colors.white54),
                      helperText: 'Tempel UID hasil buat User di Firebase Console',
                      helperStyle: TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'UID Firebase wajib diisi';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
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
                      const SnackBar(content: Text('Data operator berhasil ditambahkan')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0088FF)),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
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
          backgroundColor: const Color(0xFF12121A),
          title: const Text('Hapus Akses Operator?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus akses untuk operator $name? Operator tidak akan bisa mengakses dashboard lagi.', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('users').doc(docId).delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Akses operator $name telah dihapus')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
