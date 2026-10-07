import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ShippingAddress shippingAddress;

  const PaymentScreen({
    super.key,
    required this.shippingAddress,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = AppConstants.paymentCod;
  final _cardFormKey = GlobalKey<FormState>();
  final _upiFormKey = GlobalKey<FormState>();

  final _cardNumberController =
      TextEditingController(text: '4532 8912 3456 7890');
  final _cardExpiryController = TextEditingController(text: '12/28');
  final _cardCvvController = TextEditingController(text: '888');
  final _upiIdController = TextEditingController(text: 'alex@okaxis');

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _processMockPayment() async {
    // Validate custom mock payment inputs
    if (_selectedMethod == AppConstants.paymentCard) {
      if (!_cardFormKey.currentState!.validate()) return;
    } else if (_selectedMethod == AppConstants.paymentUpi) {
      if (!_upiFormKey.currentState!.validate()) return;
    }

    final cart = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();

    // Show simulated 2-second processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Processing Mock Payment...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Communicating with secure server',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 2-second simulated delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final placedOrder = await orderProv.placeOrder(
        cartItems: cart.items,
        total: cart.grandTotal,
        address: widget.shippingAddress,
        paymentMethod: _selectedMethod,
      );

      // Dismiss dialog
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      // Navigate to Success Screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: placedOrder),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment/Order failed: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount Payable:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${AppConstants.currencySymbol}${cart.grandTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Select Payment Option',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Option 1: Cash on Delivery
            _buildPaymentOptionTile(
              title: AppConstants.paymentCod,
              subtitle: 'Pay with cash upon delivery of your parcel',
              icon: Icons.local_shipping_outlined,
              value: AppConstants.paymentCod,
            ),
            const SizedBox(height: 12),

            // Option 2: Fake Card
            _buildPaymentOptionTile(
              title: AppConstants.paymentCard,
              subtitle: 'Simulated Credit / Debit Card (Visa, MasterCard)',
              icon: Icons.credit_card_rounded,
              value: AppConstants.paymentCard,
            ),
            if (_selectedMethod == AppConstants.paymentCard) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Form(
                  key: _cardFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _cardNumberController,
                        label: 'Card Number',
                        hintText: '1234 5678 9012 3456',
                        prefixIcon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        validator: Validators.validateCardNumber,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _cardExpiryController,
                              label: 'Expiry',
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.datetime,
                              validator: Validators.validateExpiryDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _cardCvvController,
                              label: 'CVV',
                              hintText: '123',
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              validator: Validators.validateCvv,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Option 3: Fake UPI
            _buildPaymentOptionTile(
              title: AppConstants.paymentUpi,
              subtitle: 'Instant Mock UPI Transfer (Google Pay, PhonePe, Paytm)',
              icon: Icons.account_balance_wallet_outlined,
              value: AppConstants.paymentUpi,
            ),
            if (_selectedMethod == AppConstants.paymentUpi) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Form(
                  key: _upiFormKey,
                  child: CustomTextField(
                    controller: _upiIdController,
                    label: 'Virtual Payment Address (VPA / UPI ID)',
                    hintText: 'username@okhdfcbank',
                    prefixIcon: Icons.alternate_email_rounded,
                    validator: Validators.validateUpiId,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 36),

            // Submit Payment Button
            CustomButton(
              text: 'Pay & Place Order',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _processMockPayment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMethod = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
