import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatting/money.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/pricing/checkout_pricing.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _payment = 'card';

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _zip = TextEditingController();
  final _card = TextEditingController();
  final _exp = TextEditingController();
  final _cvv = TextEditingController();
  final _upi = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AppState>().cart.isEmpty) {
        context.go('/cart');
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _zip.dispose();
    _card.dispose();
    _exp.dispose();
    _cvv.dispose();
    _upi.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_payment == 'card') {
      if (_card.text.isEmpty || _exp.text.isEmpty || _cvv.text.isEmpty) return;
    } else {
      if (_upi.text.isEmpty) return;
    }

    final address =
        '${_line1.text}, ${_line2.text.isNotEmpty ? '${_line2.text}, ' : ''}${_city.text} ${_zip.text} · ${_name.text}';

    context.read<AppState>().placeOrder(
          address: address,
          paymentMethod: _payment,
        );
    context.go('/order-success');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final subtotal = app.cartTotal;
    final ship = CheckoutPricing.shippingFlat;
    final tax = CheckoutPricing.tax(subtotal);
    final total = CheckoutPricing.grandTotal(subtotal);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
          children: [
            Text('Delivery Address', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            LuxeTextField(
              controller: _name,
              label: 'Full Name',
              hint: 'John Doe',
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            LuxeTextField(
              controller: _phone,
              label: 'Phone Number',
              hint: '+1 (555) 000-0000',
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            LuxeTextField(
              controller: _line1,
              label: 'Address Line 1',
              hint: '123 Main Street',
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            LuxeTextField(controller: _line2, label: 'Address Line 2', hint: 'Apt 4B'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: LuxeTextField(
                    controller: _city,
                    label: 'City',
                    hint: 'New York',
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: LuxeTextField(
                    controller: _zip,
                    label: 'ZIP Code',
                    hint: '10001',
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text('Payment Method', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _PaymentTile(
              title: 'Credit / Debit Card',
              value: 'card',
              groupValue: _payment,
              leading: const Icon(Icons.credit_card_rounded, color: AppColors.gold),
              onChanged: (v) => setState(() => _payment = v!),
            ),
            const SizedBox(height: 10),
            _PaymentTile(
              title: 'UPI',
              value: 'upi',
              groupValue: _payment,
              leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
              onChanged: (v) => setState(() => _payment = v!),
            ),
            const SizedBox(height: 14),
            if (_payment == 'card') ...[
              LuxeTextField(
                controller: _card,
                label: 'Card Number',
                hint: '1234 5678 9012 3456',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: LuxeTextField(
                      controller: _exp,
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LuxeTextField(
                      controller: _cvv,
                      label: 'CVV',
                      hint: '123',
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ] else ...[
              LuxeTextField(
                controller: _upi,
                label: 'UPI ID',
                hint: 'yourname@upi',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _SummaryRow('Subtotal', usd.format(subtotal)),
                  _SummaryRow('Shipping', usd.format(ship)),
                  _SummaryRow('Tax (8%)', usd.format(tax)),
                  const Divider(height: 22, color: AppColors.divider),
                  Row(
                    children: [
                      Text('Total', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text(
                        usd.format(total),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LuxeButton(
              label: 'Place Order — ${usd.format(total)}',
              expanded: true,
              onPressed: app.cart.isEmpty ? null : () => _submit(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.leading,
  });

  final String title;
  final String value;
  final String groupValue;
  final void Function(String?) onChanged;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.gold : AppColors.divider, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            leading,
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.left, this.right);

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(left, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(right, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
