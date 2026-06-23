import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/retro_scaffold.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return RetroScaffold(
      showBackButton: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form eyebrow header
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
                    'ADD CUSTOMER / PENDAFTARAN MEMBER BARU',
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
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    border: Border.all(color: AppColors.frameInk),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftarkan pelanggan baru untuk menikmati sistem akumulasi poin dan potongan harga otomatis sesuai tingkatan level.',
                        style: GoogleFonts.tinos(
                          color: AppColors.ink,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name label in Times New Roman
                      Text(
                        'Nama Lengkap / Full Name:',
                        style: GoogleFonts.tinos(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Name Input
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.tinos(color: AppColors.ink),
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama lengkap member...',
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.ink),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap wajib diisi';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama minimal terdiri dari 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone label
                      Text(
                        'Nomor Handphone / Telephone Number:',
                        style: GoogleFonts.tinos(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Phone Input
                      TextFormField(
                        controller: _phoneController,
                        style: GoogleFonts.tinos(color: AppColors.ink),
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 08123456789',
                          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.ink),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor handphone wajib diisi';
                          }
                          if (value.trim().length < 9) {
                            return 'Nomor handphone minimal 9 digit';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Submit Button - primary-button: black rectangular filled block
                      GestureDetector(
                        onTap: _isLoading ? null : _saveMember,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.frameInk,
                            border: Border.all(color: AppColors.frameInk, width: 1),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      color: AppColors.canvas,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'DAFTARKAN MEMBER BARU',
                                    style: GoogleFonts.arimo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.canvas,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final memberService = ref.read(memberServiceProvider);

    try {
      await memberService.addMember(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Member baru berhasil didaftarkan',
              style: GoogleFonts.tinos(),
            ),
            backgroundColor: AppColors.tintSage,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mendaftarkan member: $e',
              style: GoogleFonts.tinos(),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
