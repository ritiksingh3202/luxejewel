import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/validation/validators.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_text_field.dart';

/// Reached from the password-recovery email link, or from Settings › Change password.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final ok = await runWithFeedback(
      context,
      () => context.read<AuthController>().updatePassword(_password.text),
      success: 'Password updated',
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final recovery = context.watch<AuthController>().passwordRecovery;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: recovery
            ? null
            : IconButton(
                onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
        title: const Text('Choose New Password'),
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
                  LuxeTextField(
                    controller: _password,
                    label: 'New Password',
                    hint: 'At least 8 characters',
                    obscure: true,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: Validators.newPassword,
                  ),
                  const SizedBox(height: 16),
                  LuxeTextField(
                    controller: _confirm,
                    label: 'Confirm Password',
                    hint: 'Repeat new password',
                    obscure: true,
                    validator: Validators.confirmPassword(() => _password.text),
                  ),
                  const SizedBox(height: 22),
                  LuxeButton(
                    label: _loading ? 'Saving…' : 'Update Password',
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
