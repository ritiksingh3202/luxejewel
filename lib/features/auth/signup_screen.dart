import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_logo.dart';
import '../../shared/widgets/luxe_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    const LuxeLogo(size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text('Join the world of luxury', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 32),
                    LuxeTextField(
                      controller: _name,
                      label: 'Full Name',
                      hint: 'John Doe',
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    LuxeTextField(
                      controller: _email,
                      label: 'Email Address',
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    LuxeTextField(
                      controller: _phone,
                      label: 'Phone Number',
                      hint: '+1 (555) 000-0000',
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    LuxeTextField(
                      controller: _password,
                      label: 'Password',
                      hint: 'Create a strong password',
                      obscure: _obscure,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                          side: const BorderSide(color: AppColors.divider),
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.gold;
                            }
                            return Colors.transparent;
                          }),
                          checkColor: AppColors.bgPrimary,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text.rich(
                              TextSpan(
                                style: Theme.of(context).textTheme.bodySmall,
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LuxeButton(
                      label: _loading ? 'Creating account…' : 'Create Account',
                      expanded: true,
                      onPressed: _loading
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              if (!_agreed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please accept the terms')),
                                );
                                return;
                              }
                              setState(() => _loading = true);
                              await context.read<AuthController>().signUp(
                                    name: _name.text,
                                    email: _email.text,
                                    password: _password.text,
                                    phone: _phone.text,
                                  );
                              if (!mounted) return;
                              setState(() => _loading = false);
                              context.go('/home');
                            },
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Or sign up with', style: Theme.of(context).textTheme.bodySmall),
                        ),
                        const Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                            label: const Text('Google'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.apple_rounded, size: 22),
                            label: const Text('Apple'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                'Sign In',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
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
}
