import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _walletBalance = 2450.00;
  bool _autoApplyAtCheckout = true;

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN-9021',
      'title': 'Cashback for Order #ORD-8412',
      'subtitle': 'Festive 10% Electronics Cashback',
      'amount': 250.00,
      'isCredit': true,
      'date': 'Today, 2:45 PM',
      'status': 'Completed',
    },
    {
      'id': 'TXN-8874',
      'title': 'Instant Refund for Return #RET-4412',
      'subtitle': 'Desk Lamp returned - Credited to Wallet',
      'amount': 45.00,
      'isCredit': true,
      'date': 'Yesterday, 11:20 AM',
      'status': 'Completed',
    },
    {
      'id': 'TXN-8710',
      'title': 'Paid for Order #ORD-7910',
      'subtitle': 'Debited via StarShop Wallet',
      'amount': 120.00,
      'isCredit': false,
      'date': '08 Oct 2026',
      'status': 'Completed',
    },
    {
      'id': 'TXN-8512',
      'title': 'Wallet Top-Up via UPI',
      'subtitle': 'Added from HDFC Bank UPI',
      'amount': 1500.00,
      'isCredit': true,
      'date': '05 Oct 2026',
      'status': 'Completed',
    },
  ];

  final List<Map<String, dynamic>> _savedCards = [
    {
      'bank': 'HDFC Bank',
      'last4': '4242',
      'type': 'Visa Platinum',
      'isDefault': true,
    },
    {
      'bank': 'State Bank of India',
      'last4': '8899',
      'type': 'Mastercard World',
      'isDefault': false,
    },
  ];

  final List<Map<String, dynamic>> _savedUpi = [
    {
      'id': 'starshopper@okhdfcbank',
      'app': 'Google Pay',
      'isDefault': true,
    },
    {
      'id': '9876543210@paytm',
      'app': 'Paytm UPI',
      'isDefault': false,
    },
  ];

  void _showAddMoneyDialog() {
    final controller = TextEditingController(text: '500');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('Add Money to Wallet'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter amount to top-up:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '${AppConstants.currencySymbol} ',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [200, 500, 1000, 2000].map((amt) {
                return InkWell(
                  onTap: () => controller.text = '$amt',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF4F46E5).withOpacity(0.2)),
                    ),
                    child: Text('+${AppConstants.currencySymbol}$amt',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5))),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final double? amt = double.tryParse(controller.text);
              if (amt != null && amt > 0) {
                setState(() {
                  _walletBalance += amt;
                  _transactions.insert(0, {
                    'id': 'TXN-${DateTime.now().millisecondsSinceEpoch % 10000}',
                    'title': 'Instant Wallet Top-Up',
                    'subtitle': 'Credited via Secure Payment Gateway',
                    'amount': amt,
                    'isCredit': true,
                    'date': 'Just now',
                    'status': 'Completed',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    content: Text(
                        'Successfully added ${AppConstants.currencySymbol}${amt.toStringAsFixed(2)} to your Wallet!'),
                  ),
                );
              }
            },
            child: const Text('Add Instantly'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numberCtrl,
              keyboardType: TextInputType.number,
              maxLength: 16,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: expCtrl,
              decoration: const InputDecoration(
                labelText: 'Expiry (MM/YY)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final num = numberCtrl.text.trim();
              if (num.length >= 4) {
                setState(() {
                  _savedCards.add({
                    'bank': 'Verified Card',
                    'last4': num.substring(num.length - 4),
                    'type': 'Debit/Credit',
                    'isDefault': false,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment card saved securely!')),
                );
              }
            },
            child: const Text('Save Card'),
          ),
        ],
      ),
    );
  }

  void _showAddUpiDialog() {
    final upiCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add UPI ID / VPA'),
        content: TextField(
          controller: upiCtrl,
          decoration: const InputDecoration(
            labelText: 'UPI ID (e.g. mobile@upi)',
            hintText: 'user@okhdfcbank',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final id = upiCtrl.text.trim();
              if (id.contains('@')) {
                setState(() {
                  _savedUpi.add({
                    'id': id,
                    'app': 'UPI Gateway',
                    'isDefault': false,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UPI ID verified and linked!')),
                );
              }
            },
            child: const Text('Verify & Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StarShop Wallet & Payments'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF047857), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'StarShop Wallet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Instant Refunds Active',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '${AppConstants.currencySymbol}${_walletBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Usable across all StarShop orders & 1-click checkout',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF047857),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Money',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _showAddMoneyDialog,
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Transfer to Bank',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Withdrawal to linked Bank Account initiated (Zero Fee).'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pay Later Credit Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.credit_score_rounded,
                        color: Color(0xFF6366F1), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StarShop Pay Later: Active',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Approved Credit Limit: \$10,000 (0% Interest for 30 Days)',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('APPROVED',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Auto-Apply Toggle
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: SwitchListTile(
                value: _autoApplyAtCheckout,
                onChanged: (v) => setState(() => _autoApplyAtCheckout = v),
                title: const Text('Auto-apply wallet balance at checkout',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: const Text('Deduct wallet funds before charging card/UPI',
                    style: TextStyle(fontSize: 11)),
                secondary: const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B)),
              ),
            ),
            const SizedBox(height: 24),

            // Saved Cards Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saved Cards (PCI-DSS Encrypted)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Card'),
                  onPressed: _showAddCardDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._savedCards.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card_rounded,
                          color: Color(0xFF4F46E5), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${c['bank']} •••• ${c['last4']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(c['type'],
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (c['isDefault'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('DEFAULT',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F46E5))),
                        ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),

            // Saved UPI IDs Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saved UPI Handles',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add UPI'),
                  onPressed: _showAddUpiDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._savedUpi.map((u) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_rounded,
                          color: Color(0xFF059669), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u['id'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(u['app'],
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (u['isDefault'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('DEFAULT',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669))),
                        ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // Recent Transactions Section
            const Text(
              'Transactions & Refund History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final t = _transactions[idx];
                final isCredit = t['isCredit'] == true;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCredit
                              ? const Color(0xFF10B981).withOpacity(0.12)
                              : const Color(0xFFEF4444).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isCredit
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('${t['subtitle']} • ${t['date']}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600])),
                          ],
                        ),
                      ),
                      Text(
                        '${isCredit ? '+' : '-'}${AppConstants.currencySymbol}${(t['amount'] as double).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCredit
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
