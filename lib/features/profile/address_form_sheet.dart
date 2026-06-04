import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/validation/validators.dart';
import '../../domain/models/address.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_text_field.dart';

/// Opens a create/edit address sheet; returns the saved address or null.
Future<Address?> showAddressForm(BuildContext context, {Address? initial}) {
  return showModalBottomSheet<Address>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.bgSecondary,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AddressForm(initial: initial),
  );
}

class _AddressForm extends StatefulWidget {
  const _AddressForm({this.initial});

  final Address? initial;

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.fullName);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _line1 = TextEditingController(text: widget.initial?.line1);
  late final _line2 = TextEditingController(text: widget.initial?.line2);
  late final _city = TextEditingController(text: widget.initial?.city);
  late final _zip = TextEditingController(text: widget.initial?.postalCode);
  late final _country = TextEditingController(text: widget.initial?.country ?? 'US');
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _line1, _line2, _city, _zip, _country]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    Address? saved;
    final ok = await runWithFeedback(context, () async {
      saved = await context.read<AppState>().saveAddress(
            Address(
              id: widget.initial?.id,
              fullName: _name.text,
              phone: _phone.text,
              line1: _line1.text,
              line2: _line2.text,
              city: _city.text,
              postalCode: _zip.text,
              country: _country.text,
              isDefault: widget.initial?.isDefault ?? false,
            ),
          );
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.initial == null ? 'New Address' : 'Edit Address',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              LuxeTextField(controller: _name, label: 'Full Name', hint: 'John Doe', validator: Validators.name),
              const SizedBox(height: 14),
              LuxeTextField(
                controller: _phone,
                label: 'Phone Number',
                hint: '+1 (555) 000-0000',
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 14),
              LuxeTextField(
                controller: _line1,
                label: 'Address Line 1',
                hint: '123 Main Street',
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: 14),
              LuxeTextField(controller: _line2, label: 'Address Line 2 (optional)', hint: 'Apt 4B'),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LuxeTextField(
                      controller: _city,
                      label: 'City',
                      hint: 'New York',
                      validator: (v) => Validators.required(v, 'City'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LuxeTextField(
                      controller: _zip,
                      label: 'ZIP / Postal Code',
                      hint: '10001',
                      validator: Validators.postalCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LuxeTextField(
                controller: _country,
                label: 'Country',
                hint: 'US',
                validator: (v) => Validators.required(v, 'Country'),
              ),
              const SizedBox(height: 22),
              LuxeButton(
                label: _saving ? 'Saving…' : 'Save Address',
                expanded: true,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
