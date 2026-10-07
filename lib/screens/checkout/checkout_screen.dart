import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../profile/addresses_screen.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _couponController = TextEditingController();

  ShippingAddress? _chosenSavedAddress;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final savedAddresses = auth.currentUser?.savedAddresses ?? [];

    if (savedAddresses.isNotEmpty) {
      final defaultAddr = savedAddresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => savedAddresses.first,
      );
      _populateFromAddress(defaultAddr);
    } else if (user != null) {
      _nameController.text = user.name;
      if (user.phoneNumber != null) _phoneController.text = user.phoneNumber!;
      if (user.address != null) _streetController.text = user.address!;
    }
  }

  void _populateFromAddress(ShippingAddress addr) {
    setState(() {
      _chosenSavedAddress = addr;
      _nameController.text = addr.fullName;
      _phoneController.text = addr.phone;
      _streetController.text = addr.street;
      _cityController.text = addr.city;
      _stateController.text = addr.state;
      _postalCodeController.text = addr.postalCode;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _fillSampleAddress() {
    setState(() {
      _chosenSavedAddress = null;
      _nameController.text = 'Abhishek Kumar';
      _phoneController.text = '+91 9876543210';
      _streetController.text = 'Flat 402, Green Glen Layout, Bellandur';
      _cityController.text = 'Bengaluru';
      _stateController.text = 'Karnataka';
      _postalCodeController.text = '560103';
    });
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) return;

    final address = ShippingAddress(
      id: _chosenSavedAddress?.id,
      label: _chosenSavedAddress?.label ?? 'Delivery',
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
    );

    context.read<CartProvider>().setSelectedAddress(address);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(shippingAddress: address),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final savedAddresses = auth.currentUser?.savedAddresses ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Free Shipping Progress Banner
              if (cart.shippingFee > 0 && cart.amountNeededForFreeShipping > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          color: Color(0xFFB45309), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Add ${AppConstants.currencySymbol}${cart.amountNeededForFreeShipping.toStringAsFixed(2)} more to unlock FREE Delivery!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Shipping Address Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (savedAddresses.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddressesScreen(
                                  selectMode: true,
                                  onAddressSelected: (selected) {
                                    _populateFromAddress(selected);
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bookmark_outline, size: 16),
                          label: const Text('Saved'),
                        ),
                      TextButton.icon(
                        onPressed: _fillSampleAddress,
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: const Text('Auto-Fill'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _nameController,
                label: 'Recipient Full Name',
                hintText: 'John Doe',
                prefixIcon: Icons.person_outline_rounded,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _phoneController,
                label: 'Mobile Phone Number',
                hintText: '+91 98765 43210',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _streetController,
                label: 'Street Address & Apartment',
                hintText: '123 Main Street, Suite 4A',
                prefixIcon: Icons.location_on_outlined,
                validator: (val) => Validators.validateRequired(val, 'Street Address'),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'Bengaluru',
                      validator: (val) => Validators.validateRequired(val, 'City'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'Karnataka',
                      validator: (val) => Validators.validateRequired(val, 'State'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _postalCodeController,
                label: 'Postal / PIN Code',
                hintText: '560103',
                prefixIcon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                validator: Validators.validatePostalCode,
              ),
              const SizedBox(height: 24),

              // Coupon & Promo Code Section
              const Text(
                'Coupons & Offers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cart.appliedCoupon != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF10B981), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${cart.appliedCoupon!.code} Applied!',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => cart.removeCoupon(),
                            child: const Text('Remove',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                      Text(
                        'You saved ${AppConstants.currencySymbol}${cart.discountAmount.toStringAsFixed(2)} on this order.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                hintText: 'Enter Coupon Code',
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            onPressed: () {
                              final err = cart.applyCoupon(_couponController.text);
                              if (err != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                              } else {
                                _couponController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF10B981),
                                    content: Text('Coupon applied successfully!'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['WELCOME50', 'EASE20', 'FREESHIP', 'FESTIVE10'].map((c) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(c, style: const TextStyle(fontSize: 11)),
                                onPressed: () {
                                  _couponController.text = c;
                                  final err = cart.applyCoupon(c);
                                  if (err != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(err)),
                                    );
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Order Summary Card
              const Text(
                'Price Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.name} x${item.quantity}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '${AppConstants.currencySymbol}${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price (Gross Subtotal):'),
                        Text(
                          '${AppConstants.currencySymbol}${cart.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (cart.discountAmount > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Coupon Discount (${cart.appliedCoupon?.code}):'),
                          Text(
                            '-${AppConstants.currencySymbol}${cart.discountAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST (18% - CGST 9% + SGST 9%):'),
                        Text(
                          '${AppConstants.currencySymbol}${cart.tax.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Charges:'),
                        Text(
                          cart.shippingFee == 0
                              ? 'FREE'
                              : '${AppConstants.currencySymbol}${cart.shippingFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: cart.shippingFee == 0 ? const Color(0xFF10B981) : null,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${AppConstants.currencySymbol}${cart.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Proceed Button
              CustomButton(
                text: 'Continue to Payment',
                icon: Icons.payment_rounded,
                onPressed: _proceedToPayment,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
