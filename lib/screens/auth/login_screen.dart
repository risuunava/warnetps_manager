import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/retro_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return RetroScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.frameInk, width: 1.0),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title block in Arial Black (Arimo w900)
                    Center(
                      child: Text(
                        'MANAJEMEN PUSAT',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.ink,
                              letterSpacing: 0.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Serif description (Tinos)
                    Center(
                      child: Text(
                        'Silakan masuk untuk mengelola outlet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email label in Times New Roman
                    Text(
                      'Email Address / Alamat Surel:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),

                    // Email text field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'admin@perusahaan.com',
                        prefixIcon: Icon(Icons.mail_outline, color: AppColors.ink),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password label
                    Text(
                      'Password / Kata Sandi:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.ink),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    // Error message in flat red block
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary, // Dell Red
                          border: Border.all(color: AppColors.frameInk),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.canvas,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Login button - button-primary (Black filled, white bold text, no radius)
                    GestureDetector(
                      onTap: _isLoading ? null : _handleLogin,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.frameInk,
                          border: Border.all(color: AppColors.frameInk, width: 1.0),
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
                                  'MASUK SEKARANG',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: AppColors.canvas,
                                      ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    // Underlined Link in Classic blue (Times New Roman)
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Lupa password?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.link,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.link,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        context.go('/');
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Login gagal. Coba lagi.';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
