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
  String _selectedMethod = 'UPI (PhonePe / GPay)';
  String _selectedUpiApp = 'PhonePe';
  String _selectedBank = 'HDFC Bank';

  final _cardFormKey = GlobalKey<FormState>();
  final _upiFormKey = GlobalKey<FormState>();

  final _cardNumberController =
      TextEditingController(text: '4532 8912 3456 7890');
  final _cardExpiryController = TextEditingController(text: '12/28');
  final _cardCvvController = TextEditingController(text: '888');
  final _cardHolderController = TextEditingController(text: 'Rajnesh Kumar');
  final _upiIdController = TextEditingController(text: 'rajnesh@ibl');

  final List<String> _upiApps = ['PhonePe', 'Google Pay', 'Paytm', 'BHIM UPI'];
  final List<String> _banks = [
    'HDFC Bank',
    'State Bank of India',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank'
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _processMockPayment() async {
    if (_selectedMethod.startsWith('Credit / Debit Card')) {
      if (!_cardFormKey.currentState!.validate()) return;
    } else if (_selectedMethod.startsWith('UPI')) {
      if (_selectedUpiApp == 'BHIM UPI' && !_upiFormKey.currentState!.validate()) {
        return;
      }
    }

    final cart = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Processing via $_selectedMethod...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '256-bit SSL Encrypted • RBI Compliant Mock Gateway',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 2-second simulation delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final methodTitle = _selectedMethod.startsWith('UPI')
          ? 'UPI ($_selectedUpiApp)'
          : (_selectedMethod.startsWith('Net Banking')
              ? 'Net Banking ($_selectedBank)'
              : _selectedMethod);

      final placedOrder = await orderProv.placeOrder(
        cartItems: cart.items,
        total: cart.grandTotal,
        address: widget.shippingAddress,
        paymentMethod: methodTitle,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

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
          content: Text('Payment failed: $e'),
          backgroundColor: const Color(0xFFEF4444),
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
        title: const Text('Payment Options'),
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
                    'Total Payable Amount:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
              'Preferred Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Option 1: UPI (PhonePe, GPay, Paytm)
            _buildOptionCard(
              title: 'UPI (Instant Transfer)',
              subtitle: 'Google Pay, PhonePe, Paytm, BHIM UPI',
              icon: Icons.account_balance_wallet_outlined,
              value: 'UPI (PhonePe / GPay)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose UPI App:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _upiApps.map((app) {
                      final isSel = _selectedUpiApp == app;
                      return ChoiceChip(
                        label: Text(app),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) setState(() => _selectedUpiApp = app);
                        },
                      );
                    }).toList(),
                  ),
                  if (_selectedUpiApp == 'BHIM UPI') ...[
                    const SizedBox(height: 12),
                    Form(
                      key: _upiFormKey,
                      child: CustomTextField(
                        controller: _upiIdController,
                        label: 'UPI ID (e.g. mobile@upi)',
                        hintText: 'user@okaxis',
                        prefixIcon: Icons.alternate_email,
                        validator: Validators.validateUpiId,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Credit / Debit Card
            _buildOptionCard(
              title: 'Credit / Debit Cards',
              subtitle: 'Visa, MasterCard, RuPay, Maestro',
              icon: Icons.credit_card_rounded,
              value: 'Credit / Debit Card',
              child: Form(
                key: _cardFormKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _cardHolderController,
                      label: 'Cardholder Name',
                      hintText: 'John Doe',
                      prefixIcon: Icons.person_outline,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 12),
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
            const SizedBox(height: 12),

            // Option 3: Net Banking
            _buildOptionCard(
              title: 'Net Banking',
              subtitle: 'All Major Indian Banks Supported',
              icon: Icons.account_balance_outlined,
              value: 'Net Banking',
              child: DropdownButtonFormField<String>(
                value: _selectedBank,
                decoration: const InputDecoration(
                  labelText: 'Select Bank',
                  border: OutlineInputBorder(),
                ),
                items: _banks
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBank = val);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Option 4: Cash on Delivery
            _buildOptionCard(
              title: 'Cash on Delivery (COD)',
              subtitle: 'Pay via Cash or QR code on parcel delivery',
              icon: Icons.local_shipping_outlined,
              value: AppConstants.paymentCod,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFB45309), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Keep exact cash ready or scan QR code on delivery with the courier executive.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Pay Button
            CustomButton(
              text: 'Pay & Confirm Order (${AppConstants.currencySymbol}${cart.grandTotal.toStringAsFixed(2)})',
              icon: Icons.verified_user_outlined,
              onPressed: _processMockPayment,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '100% Safe & Secure Mock Checkout',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    Widget? child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedMethod == value;

    return Container(
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
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _selectedMethod = value;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: theme.colorScheme.primary, size: 22),
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
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<String>(
                    value: value,
                    groupValue: _selectedMethod,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMethod = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (isSelected && child != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: child,
            ),
          ],
        ],
      ),
    );
  }
}
