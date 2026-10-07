import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import 'invoice_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _syncOrder() {
    final orderProv = context.read<OrderProvider>();
    final found = orderProv.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => _currentOrder,
    );
    setState(() {
      _currentOrder = found;
    });
  }

  void _showCancelDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this order? Please tell us why:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. Ordered by mistake, found better price',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final reason = controller.text.trim().isEmpty
                  ? 'Customer requested cancellation'
                  : controller.text.trim();
              Navigator.pop(ctx);
              final success = await context
                  .read<OrderProvider>()
                  .cancelOrder(_currentOrder.id, reason: reason);
              if (mounted) {
                if (success) {
                  _syncOrder();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cancelled successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to cancel order'),
                    ),
                  );
                }
              }
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Return & Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Eligible for 7-day hassle-free return. Please provide the reason for return:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. Defective item, size mismatch',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = controller.text.trim().isEmpty
                  ? 'Return requested by customer'
                  : controller.text.trim();
              Navigator.pop(ctx);
              final success = await context
                  .read<OrderProvider>()
                  .requestReturn(_currentOrder.id, reason);
              if (mounted) {
                if (success) {
                  _syncOrder();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Return request submitted for approval'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Submit Return'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check OrderProvider for latest reactive changes
    final orderProv = context.watch<OrderProvider>();
    final activeOrder = orderProv.orders.firstWhere(
      (o) => o.id == _currentOrder.id,
      orElse: () => _currentOrder,
    );

    final isCancelled = activeOrder.status == AppConstants.orderStatusCancelled;
    final isDelivered = activeOrder.status == AppConstants.orderStatusDelivered;
    final canCancel = activeOrder.status == AppConstants.orderStatusConfirmed ||
        activeOrder.status == AppConstants.orderStatusPacked;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          IconButton(
            tooltip: 'View Tax Invoice',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceScreen(order: activeOrder),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tracking Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF4338CA), const Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4338CA).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AWB Tracking ID',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activeOrder.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeOrder.trackingId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Carrier: ${activeOrder.deliveryPartner}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Est: ${DateFormat('dd MMM').format(activeOrder.estimatedDeliveryDate)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline Steps
            Text(
              'Shipment Journey',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: isCancelled
                  ? _buildCancelledTimeline(activeOrder)
                  : Column(
                      children: [
                        _buildTimelineNode(
                          title: 'Order Confirmed',
                          subtitle: DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(activeOrder.timeline.confirmedAt),
                          description:
                              'Seller accepted your order and generated invoice #${activeOrder.invoiceNumber}',
                          isCompleted: true,
                          isActive:
                              activeOrder.status == AppConstants.orderStatusConfirmed,
                          isLast: false,
                        ),
                        _buildTimelineNode(
                          title: 'Packed & Ready',
                          subtitle: activeOrder.timeline.packedAt != null
                              ? DateFormat('MMM dd, yyyy • hh:mm a')
                                  .format(activeOrder.timeline.packedAt!)
                              : 'Pending packing',
                          description:
                              'Item verified for quality and packaged securely',
                          isCompleted: _isStepDone(activeOrder.status, 2),
                          isActive:
                              activeOrder.status == AppConstants.orderStatusPacked,
                          isLast: false,
                        ),
                        _buildTimelineNode(
                          title: 'Shipped (In Transit)',
                          subtitle: activeOrder.timeline.shippedAt != null
                              ? DateFormat('MMM dd, yyyy • hh:mm a')
                                  .format(activeOrder.timeline.shippedAt!)
                              : 'Awaiting courier pickup',
                          description:
                              'Dispatched via ${activeOrder.deliveryPartner}',
                          isCompleted: _isStepDone(activeOrder.status, 3),
                          isActive:
                              activeOrder.status == AppConstants.orderStatusShipped,
                          isLast: false,
                        ),
                        _buildTimelineNode(
                          title: 'Out for Delivery',
                          subtitle: activeOrder.timeline.outForDeliveryAt != null
                              ? DateFormat('MMM dd, yyyy • hh:mm a')
                                  .format(activeOrder.timeline.outForDeliveryAt!)
                              : 'Will arrive on ${DateFormat('EEE, MMM dd').format(activeOrder.estimatedDeliveryDate)}',
                          description:
                              'Delivery executive assigned with security OTP',
                          isCompleted: _isStepDone(activeOrder.status, 4),
                          isActive: activeOrder.status ==
                              AppConstants.orderStatusOutForDelivery,
                          isLast: false,
                        ),
                        _buildTimelineNode(
                          title: 'Delivered',
                          subtitle: activeOrder.timeline.deliveredAt != null
                              ? DateFormat('MMM dd, yyyy • hh:mm a')
                                  .format(activeOrder.timeline.deliveredAt!)
                              : 'Expected by ${DateFormat('MMM dd').format(activeOrder.estimatedDeliveryDate)}',
                          description:
                              'Package handed over at delivery address',
                          isCompleted: _isStepDone(activeOrder.status, 5),
                          isActive: isDelivered,
                          isLast: true,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Return / Refund Banner if requested
            if (activeOrder.returnStatus != 'none') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: activeOrder.returnStatus == 'refunded'
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeOrder.returnStatus == 'refunded'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          activeOrder.returnStatus == 'refunded'
                              ? Icons.verified
                              : Icons.assignment_return,
                          color: activeOrder.returnStatus == 'refunded'
                              ? const Color(0xFF047857)
                              : const Color(0xFFB45309),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Return Status: ${activeOrder.returnStatus.toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: activeOrder.returnStatus == 'refunded'
                                ? const Color(0xFF047857)
                                : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reason: ${activeOrder.returnReason ?? "Not specified"}',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    if (activeOrder.refundAmount != null &&
                        activeOrder.refundAmount! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Refund of ${AppConstants.currencySymbol}${activeOrder.refundAmount!.toStringAsFixed(2)} processed to original payment method.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Delivery Address Summary
            Text(
              'Destination Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activeOrder.address.fullName} (${activeOrder.address.label})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeOrder.address.fullAddress,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contact: ${activeOrder.address.phone}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Cancel / Return / Invoice)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Tax Invoice'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoiceScreen(order: activeOrder),
                        ),
                      );
                    },
                  ),
                ),
                if (canCancel) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Order'),
                      onPressed: _showCancelDialog,
                    ),
                  ),
                ] else if (isDelivered && activeOrder.returnStatus == 'none') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3E8FF),
                        foregroundColor: const Color(0xFF7E22CE),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.assignment_return),
                      label: const Text('Return / Refund'),
                      onPressed: _showReturnDialog,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _isStepDone(String status, int stepNumber) {
    final orderMap = {
      AppConstants.orderStatusConfirmed: 1,
      AppConstants.orderStatusPacked: 2,
      AppConstants.orderStatusShipped: 3,
      AppConstants.orderStatusOutForDelivery: 4,
      AppConstants.orderStatusDelivered: 5,
    };
    final currentVal = orderMap[status] ?? 1;
    return currentVal >= stepNumber;
  }

  Widget _buildCancelledTimeline(OrderModel order) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel, color: Colors.red, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Cancelled',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reason: ${order.cancelReason ?? "Cancelled by user"}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Any online payment made will be refunded within 3-5 business days to your source account.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTimelineNode({
    required String title,
    required String subtitle,
    required String description,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    final color = isCompleted
        ? const Color(0xFF10B981)
        : (isActive ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF10B981) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2.5,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : (isActive
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 54,
                color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCompleted || isActive ? null : Colors.grey,
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
