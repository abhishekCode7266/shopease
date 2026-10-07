import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';
import '../orders/order_detail_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated / Pop Success Checkmark
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 72,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Order Placed Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Thank you for shopping with ${AppConstants.appName}. Your package is being prepared for dispatch.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Order Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Order ID:', order.id),
                        const SizedBox(height: 10),
                        _buildDetailRow('Status:', order.status),
                        const SizedBox(height: 10),
                        _buildDetailRow('Payment Mode:', order.paymentMethod),
                        const SizedBox(height: 10),
                        _buildDetailRow('Items:', '${order.items.length} items'),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Paid:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${AppConstants.currencySymbol}${order.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Buttons
                  CustomButton(
                    text: 'View Order Details',
                    icon: Icons.receipt_long_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: order),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  CustomButton(
                    text: 'Continue Shopping',
                    isOutlined: true,
                    icon: Icons.storefront_outlined,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
