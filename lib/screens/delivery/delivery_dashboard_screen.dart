import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/delivery_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/star_shop_logo.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProv = context.watch<DeliveryProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const StarShopLogo(size: 26, showText: false),
            const SizedBox(width: 8),
            const Text(
              'Delivery Hub',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Text(
                  deliveryProv.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: deliveryProv.isOnline
                        ? AppTheme.accentGreen
                        : AppTheme.textMuted,
                  ),
                ),
                Switch(
                  value: deliveryProv.isOnline,
                  activeColor: AppTheme.accentGreen,
                  onChanged: (val) {
                    deliveryProv.toggleOnlineStatus();
                  },
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryOrange,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: [
            Tab(
              icon: const Icon(Icons.two_wheeler),
              text: 'Active Tasks (${deliveryProv.activeDeliveries.length})',
            ),
            Tab(
              icon: const Icon(Icons.history_toggle_off),
              text: 'Completed (${deliveryProv.completedDeliveries.length})',
            ),
          ],
        ),
      ),
      body: deliveryProv.isOnline
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTasksTab(context, deliveryProv),
                _buildCompletedTasksTab(context, deliveryProv),
              ],
            )
          : _buildOfflineState(context, deliveryProv),
    );
  }

  Widget _buildOfflineState(
      BuildContext context, DeliveryProvider deliveryProv) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.power_settings_new,
                size: 64,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'You are Currently Offline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Switch your status to Online to start receiving StarShop customer delivery assignments and earn ₹50 per trip.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => deliveryProv.toggleOnlineStatus(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Go Online Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTasksTab(
      BuildContext context, DeliveryProvider deliveryProv) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRiderStatsHeader(deliveryProv),
        const SizedBox(height: 16),
        if (deliveryProv.activeDeliveries.isEmpty)
          _buildNoActiveTasksNotice()
        else
          ...deliveryProv.activeDeliveries
              .map((order) => _buildOrderDeliveryCard(context, deliveryProv, order)),
      ],
    );
  }

  Widget _buildCompletedTasksTab(
      BuildContext context, DeliveryProvider deliveryProv) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildEarningsSummary(deliveryProv),
        const SizedBox(height: 16),
        if (deliveryProv.completedDeliveries.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                'No completed deliveries yet today.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          )
        else
          ...deliveryProv.completedDeliveries.map(
            (order) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.check_circle, color: AppTheme.accentGreen),
                ),
                title: Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Delivered to ${order.address.fullName} • ${order.address.city}\nEarned: +₹50.00 Delivery Fee',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                isThreeLine: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRiderStatsHeader(DeliveryProvider prov) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Text(
                  '7266',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prov.riderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vehicle: ${prov.vehicleNumber}  •  ★ ${prov.rating}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active Rider',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Earned', '₹${prov.totalEarnings.toStringAsFixed(0)}'),
              _buildStatItem('Trips Done', '${prov.completedTrips}'),
              _buildStatItem('On-Time', '98.5%'),
              _buildStatItem('Master PIN', '7266'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsSummary(DeliveryProvider prov) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings & Payout Ledger',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Base Rider Payout (per trip)'),
                const Text(
                  '₹50.00',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Completed Trips'),
                Text(
                  '${prov.completedTrips}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Net Available Payout Balance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${prov.totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.accentGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveTasksNotice() {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 56, color: AppTheme.accentGreen),
          const SizedBox(height: 12),
          const Text(
            'All Caught Up!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'No pending delivery tasks in your queue right now. Keep app open to receive instant alerts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDeliveryCard(
    BuildContext context,
    DeliveryProvider prov,
    OrderModel order,
  ) {
    final isCOD = order.paymentMethod.toLowerCase().contains('cash') ||
        order.paymentMethod.toLowerCase().contains('cod');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Customer Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person_pin,
                    color: AppTheme.primaryBlue, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.address.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        order.address.fullAddress,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      if (order.deliveryNotes != null &&
                          order.deliveryNotes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Note: ${order.deliveryNotes}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Payment banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCOD
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isCOD ? Icons.money : Icons.check_circle,
                    size: 18,
                    color: isCOD ? Colors.red : AppTheme.accentGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCOD
                          ? 'Collect Cash: ₹${order.total.toStringAsFixed(2)}'
                          : 'Prepaid Order: ₹${order.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isCOD ? Colors.red.shade900 : Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Route Turnaround Simulation
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation,
                      size: 16, color: AppTheme.primaryOrange),
                  const SizedBox(width: 6),
                  const Text(
                    'Simulated Distance: 2.1 km (~7 mins away)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                if (order.status == 'Picked Up')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        prov.updateDeliveryStatus(
                            order.id, 'Out for Delivery');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Order status updated to Out for Delivery'),
                            backgroundColor: AppTheme.primaryOrange,
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('Start Delivery Run'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                else if (order.status == 'Out for Delivery')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showOtpVerificationDialog(context, prov, order),
                      icon: const Icon(Icons.verified),
                      label: const Text('Deliver (Verify Customer OTP)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Out for Delivery':
        return AppTheme.primaryOrange;
      case 'Picked Up':
      case 'Shipped':
        return AppTheme.primaryBlue;
      case 'Delivered':
        return AppTheme.accentGreen;
      default:
        return AppTheme.textMuted;
    }
  }

  void _showOtpVerificationDialog(
    BuildContext context,
    DeliveryProvider prov,
    OrderModel order,
  ) {
    final otpController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.shield_outlined, color: AppTheme.accentGreen),
                SizedBox(width: 8),
                Text('Customer OTP Verification'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask the customer for the 4-digit delivery security PIN for Order #${order.id}.',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.key, size: 16, color: AppTheme.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        'Developer / Test Master PIN: 7266',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    hintText: 'e.g. 7266',
                    errorText: errorText,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final entered = otpController.text.trim();
                  if (entered.isEmpty) {
                    setDialogState(() {
                      errorText = 'Please enter OTP';
                    });
                    return;
                  }

                  final success = await prov.verifyOtpAndCompleteDelivery(
                    orderId: order.id,
                    enteredOtp: entered,
                  );

                  if (success) {
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order #${order.id} Delivered Successfully! +₹50.00 credited to Rider ledger.',
                        ),
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    );
                  } else {
                    setDialogState(() {
                      errorText = 'Incorrect OTP! Use 7266 or customer PIN.';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm Delivery'),
              ),
            ],
          );
        },
      ),
    );
  }
}
