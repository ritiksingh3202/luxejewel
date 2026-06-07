import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../router/nav.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_empty_state.dart';
import 'address_form_sheet.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo('/profile'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Shipping Addresses'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bgPrimary,
        onPressed: () => showAddressForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: app.addresses.isEmpty
          ? const LuxeEmptyState(
              icon: Icons.location_on_outlined,
              title: 'No saved addresses',
              message: 'Add an address to speed up checkout.',
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                  itemCount: app.addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = app.addresses[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: a.isDefault ? AppColors.gold : AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(a.fullName, style: theme.titleSmall)),
                              if (a.isDefault)
                                Text('Default', style: theme.labelSmall?.copyWith(color: AppColors.gold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(a.singleLine, style: theme.bodySmall),
                          Text(a.phone, style: theme.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed: () => showAddressForm(context, initial: a),
                                child: const Text('Edit'),
                              ),
                              if (!a.isDefault)
                                TextButton(
                                  onPressed: () => runWithFeedback(context, () => app.setDefaultAddress(a.id!)),
                                  child: const Text('Set Default'),
                                ),
                              TextButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Delete address?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && context.mounted) {
                                    runWithFeedback(context, () => app.deleteAddress(a.id!));
                                  }
                                },
                                child: const Text('Delete', style: TextStyle(color: AppColors.destructive)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
