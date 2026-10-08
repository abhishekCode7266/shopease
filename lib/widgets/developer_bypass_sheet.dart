import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../screens/home/home_screen.dart';
import '../utils/sample_data.dart';

class DeveloperBypassSheet extends StatefulWidget {
  const DeveloperBypassSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DeveloperBypassSheet(),
    );
  }

  @override
  State<DeveloperBypassSheet> createState() => _DeveloperBypassSheetState();
}

class _DeveloperBypassSheetState extends State<DeveloperBypassSheet> {
  final _pinController = TextEditingController(text: '7266');
  String _selectedRole = 'admin'; // 'admin', 'seller', 'customer'
  bool _preloadDemoCart = true;
  bool _obscurePin = true;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _handleActivate() {
    final enteredPin = _pinController.text.trim();
    if (enteredPin != '7266' && enteredPin != '1234') {
      setState(() {
        _error = 'Invalid Developer PIN. Use default: 7266';
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();

    // 1. Activate Developer Bypass with chosen role
    auth.activateDeveloperBypass(
      role: _selectedRole,
      name: _selectedRole == 'admin'
          ? 'Abhishek (Super Admin)'
          : (_selectedRole == 'seller'
              ? 'Abhishek (Merchant Apex Audio)'
              : 'Abhishek (Lead Developer)'),
      email: 'abhishekCode7266@starshop.app',
      uid: 'dev_abhishek_7266',
    );

    // 2. Preload Demo Products if needed
    if (productProvider.filteredProducts.isEmpty) {
      productProvider.seedProducts(silent: true);
    }

    // 3. Preload Demo Cart if opted
    if (_preloadDemoCart) {
      final sampleItems = SampleData.sampleProducts;
      if (sampleItems.isNotEmpty) {
        cart.addToCart(sampleItems[0], quantity: 1);
        if (sampleItems.length > 1) {
          cart.addToCart(sampleItems[1], quantity: 2);
        }
      }
    }

    Navigator.of(context).pop(); // Close bottom sheet

    // Navigate to Home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Developer Bypass Active as ${_selectedRole.toUpperCase()}! All features unlocked.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag indicator bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Developer Access Portal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Exclusive Multi-Role Bypass (PIN 7266)',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Role Selector Chips
            const Text(
              'Select Entry Role:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleChip('admin', 'Super Admin', Icons.admin_panel_settings),
                const SizedBox(width: 8),
                _buildRoleChip('seller', 'Seller Hub', Icons.storefront),
                const SizedBox(width: 8),
                _buildRoleChip('customer', 'Customer', Icons.shopping_bag_outlined),
              ],
            ),
            const SizedBox(height: 16),

            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureRow(
                    icon: Icons.check_circle_outline_rounded,
                    text: 'Direct login without Firebase credentials',
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureRow(
                    icon: Icons.shield_rounded,
                    text: 'Unlock Admin Analytics, Seller Hub & AI Concierge',
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureRow(
                    icon: Icons.developer_board_rounded,
                    text: 'Developer ID: abhishekCode7266 (PIN: 7266)',
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Developer PIN input
            TextField(
              controller: _pinController,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Developer PIN Code',
                hintText: 'Enter 7266',
                prefixIcon: const Icon(Icons.pin_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePin
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePin = !_obscurePin;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 12),

            // Preload demo cart checkbox
            SwitchListTile(
              value: _preloadDemoCart,
              onChanged: (val) {
                setState(() {
                  _preloadDemoCart = val;
                });
              },
              title: const Text(
                'Pre-fill Cart with Sample Items',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Allows immediate checkout and payment testing',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 18),

            // Activate Button
            ElevatedButton(
              onPressed: _handleActivate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bypass & Enter as ${_selectedRole.toUpperCase()} (बाईपास करें)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Cancel
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel / Normal Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String roleKey, String label, IconData icon) {
    final isSelected = _selectedRole == roleKey;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = roleKey;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFF4F46E5).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Colors.white : const Color(0xFF4F46E5)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
