import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';

class AddressesScreen extends StatelessWidget {
  final bool selectMode;
  final Function(ShippingAddress)? onAddressSelected;

  const AddressesScreen({
    super.key,
    this.selectMode = false,
    this.onAddressSelected,
  });

  void _openAddressForm(BuildContext context, {ShippingAddress? existing}) {
    final nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final streetCtrl = TextEditingController(text: existing?.street ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final stateCtrl = TextEditingController(text: existing?.state ?? '');
    final pinCtrl = TextEditingController(text: existing?.postalCode ?? '');
    String label = existing?.label ?? 'Home';
    bool isDefault = existing?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: bottomInset + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existing == null ? 'Add New Address' : 'Edit Address',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Label chips
                    Row(
                      children: ['Home', 'Work', 'Other'].map((l) {
                        final isSel = label == l;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(l),
                            selected: isSel,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => label = l);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: streetCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Flat, House no., Building, Street',
                        prefixIcon: Icon(Icons.home_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: stateCtrl,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: pinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'PIN / Postal Code',
                        prefixIcon: Icon(Icons.pin_drop_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Make this my default address'),
                      value: isDefault,
                      onChanged: (val) {
                        setModalState(() => isDefault = val ?? false);
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty ||
                              phoneCtrl.text.trim().isEmpty ||
                              streetCtrl.text.trim().isEmpty ||
                              cityCtrl.text.trim().isEmpty ||
                              pinCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all required fields'),
                              ),
                            );
                            return;
                          }

                          final auth = context.read<AuthProvider>();
                          final newAddr = ShippingAddress(
                            id: existing?.id,
                            label: label,
                            fullName: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            street: streetCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            state: stateCtrl.text.trim(),
                            postalCode: pinCtrl.text.trim(),
                            isDefault: isDefault,
                          );

                          if (existing == null) {
                            auth.addAddress(newAddr);
                          } else {
                            auth.updateAddress(newAddr);
                          }

                          Navigator.pop(modalCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(existing == null
                                  ? 'Address added successfully'
                                  : 'Address updated'),
                            ),
                          );
                        },
                        child: Text(existing == null
                            ? 'Save Address'
                            : 'Update Address'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final addresses = authProv.currentUser?.savedAddresses ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(selectMode ? 'Select Delivery Address' : 'My Addresses'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddressForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No Addresses Saved',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a delivery address for fast 1-click checkout.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _openAddressForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (ctx, idx) {
                final addr = addresses[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: addr.isDefault
                          ? const Color(0xFF4F46E5)
                          : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0)),
                      width: addr.isDefault ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (selectMode && onAddressSelected != null) {
                        onAddressSelected!(addr);
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  addr.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'DEFAULT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () =>
                                    _openAddressForm(context, existing: addr),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                onPressed: () {
                                  authProv.deleteAddress(addr.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Address deleted'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            addr.fullName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            addr.fullAddress,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.75),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phone: ${addr.phone}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                          if (!addr.isDefault) ...[
                            const SizedBox(height: 10),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 16),
                              label: const Text(
                                'Set as Default Address',
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                authProv.setDefaultAddress(addr.id);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
