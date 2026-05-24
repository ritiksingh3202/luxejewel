import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_logo.dart';
import '../../shared/widgets/luxe_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
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
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text('Sign in to continue your journey', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 32),
                    LuxeTextField(
                      controller: _email,
                      label: 'Email Address',
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    LuxeTextField(
                      controller: _password,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscure: _obscure,
                      autofillHints: const [AutofillHints.password],
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LuxeButton(
                      label: _loading ? 'Signing in…' : 'Sign In',
                      expanded: true,
                      onPressed: _loading
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              setState(() => _loading = true);
                              await context.read<AuthController>().signIn(
                                    email: _email.text,
                                    password: _password.text,
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
                          child: Text('Or continue with', style: Theme.of(context).textTheme.bodySmall),
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
                          const TextSpan(text: "Don't have an account? "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => context.go('/signup'),
                              child: Text(
                                'Sign Up',
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
