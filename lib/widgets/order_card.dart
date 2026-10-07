import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.orderStatusPlaced:
        return const Color(0xFF3B82F6); // Blue
      case AppConstants.orderStatusShipped:
        return const Color(0xFFF59E0B); // Amber
      case AppConstants.orderStatusDelivered:
        return const Color(0xFF10B981); // Emerald
      case AppConstants.orderStatusCancelled:
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(order.status);
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.55),
                ),
              ),
              const Divider(height: 24),

              // Items summary
              Text(
                '${order.items.length} ${order.items.length == 1 ? "item" : "items"}: ${order.items.map((e) => "${e.name} (x${e.quantity})").join(", ")}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 12),

              // Footer: Payment & Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.payment_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order.paymentMethod,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${AppConstants.currencySymbol}${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
