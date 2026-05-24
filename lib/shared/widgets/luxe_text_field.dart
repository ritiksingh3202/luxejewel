import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class LuxeTextField extends StatelessWidget {
  const LuxeTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.suffix,
    this.inputFormatters,
    this.textInputAction,
    this.autofillHints,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
