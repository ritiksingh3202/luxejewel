import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/validation/validators.dart';
import '../../router/nav.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final ok = await runWithFeedback(
      context,
      () => context.read<AuthController>().sendPasswordReset(_email.text),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo('/login'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _sent
                        ? 'If an account exists for ${_email.text.trim()}, a reset link is on its way. '
                            'Open it on this device to choose a new password.'
                        : 'Enter your account email and we\'ll send you a link to reset your password.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  LuxeTextField(
                    controller: _email,
                    label: 'Email Address',
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),
                  LuxeButton(
                    label: _loading ? 'Sending…' : (_sent ? 'Resend Link' : 'Send Reset Link'),
                    expanded: true,
                    onPressed: _loading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
