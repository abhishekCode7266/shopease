import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/cart_item_tile.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                      'Are you sure you want to remove all items from your cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clearCart();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyStateView(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Your Cart is Empty',
              subtitle:
                  'Looks like you haven\'t added any items to your shopping cart yet.',
              buttonText: 'Continue Shopping',
              onButtonPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            )
          : Column(
              children: [
                // List of Cart Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemTile(item: item);
                    },
                  ),
                ),

                // Order Summary & Checkout Bottom Sheet
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal (${cart.totalQuantity} items)',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${AppConstants.currencySymbol}${cart.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Coupon Discount if active
                        if (cart.discountAmount > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discount (${cart.appliedCoupon?.code})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '-${AppConstants.currencySymbol}${cart.discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Estimated GST 18%
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GST (18% - CGST 9% + SGST 9%)',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${AppConstants.currencySymbol}${cart.tax.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Shipping
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery Fee',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              cart.shippingFee == 0
                                  ? 'FREE'
                                  : '${AppConstants.currencySymbol}${cart.shippingFee.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cart.shippingFee == 0
                                    ? const Color(0xFF10B981)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Total Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                        const SizedBox(height: 20),

                        // Checkout Button
                        CustomButton(
                          text: 'Proceed to Checkout',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
