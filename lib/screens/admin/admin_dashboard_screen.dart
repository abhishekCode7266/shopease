import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_item_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBroadcastDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String type = 'promo';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            title: const Text('Dispatch Platform Broadcast'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'This notification will be instantly delivered to all active StarShop mobile & web users.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(
                        labelText: 'Notification Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'promo', child: Text('Promotional Offer')),
                        DropdownMenuItem(value: 'system', child: Text('System Maintenance')),
                        DropdownMenuItem(value: 'order', child: Text('Order Alert')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => type = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Broadcast Title',
                        hintText: 'e.g. Flash Sale Alert! 50% Off Today',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Message Body',
                        hintText: 'Use code FESTIVE10 at checkout for instant savings.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final body = bodyCtrl.text.trim();
                  if (title.isEmpty || body.isEmpty) return;

                  context.read<NotificationProvider>().addNotification(
                        NotificationItemModel(
                          id: 'broadcast_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          body: body,
                          type: type,
                          createdAt: DateTime.now(),
                        ),
                      );

                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF10B981),
                      content: Text('Broadcast alert dispatched successfully!'),
                    ),
                  );
                },
                child: const Text('Send Broadcast'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adminProv = context.watch<AdminProvider>();
    final orderProv = context.watch<OrderProvider>();
    final prodProv = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: Color(0xFF4F46E5), size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin Central',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Full Platform Governance • Antigravity 2.0',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Send Platform Broadcast',
            icon: const Icon(Icons.campaign_outlined),
            onPressed: _showBroadcastDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(icon: Icon(Icons.analytics_outlined), text: 'Analytics'),
            Tab(
              icon: const Icon(Icons.verified_user_outlined),
              text: 'Sellers (${adminProv.sellerApplications.length})',
            ),
            const Tab(icon: Icon(Icons.people_outline), text: 'User Moderation'),
            const Tab(icon: Icon(Icons.local_offer_outlined), text: 'Coupons'),
            const Tab(icon: Icon(Icons.settings_outlined), text: 'Site Settings'),
            const Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Logistics Fleet'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Analytics & Sales Chart Tab
          _buildAnalyticsTab(theme, isDark, adminProv, orderProv, prodProv),

          // 2. Sellers Approvals Tab
          _buildSellersTab(theme, isDark, adminProv),

          // 3. User Moderation Tab
          _buildUserModerationTab(theme, isDark, adminProv),

          // 4. Coupons & Offers Tab
          _buildCouponsTab(theme, isDark),

          // 5. Marketplace Site Settings Tab
          _buildSiteSettingsTab(theme, isDark),

          // 6. Logistics Fleet Oversight Tab
          _buildLogisticsFleetTab(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(
    ThemeData theme,
    bool isDark,
    AdminProvider adminProv,
    OrderProvider orderProv,
    ProductProvider prodProv,
  ) {
    final maxMonthlySales = adminProv.monthlySales
        .fold<double>(0.0, (m, e) => e.sales > m ? e.sales : m);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildKPICard(
                'Gross Merchandise Vol',
                '${AppConstants.currencySymbol}${adminProv.totalSales.toStringAsFixed(0)}',
                Icons.account_balance_wallet_outlined,
                const Color(0xFF4F46E5),
                isDark,
              ),
              _buildKPICard(
                'Platform Net Revenue (20%)',
                '${AppConstants.currencySymbol}${adminProv.platformNetRevenue.toStringAsFixed(0)}',
                Icons.trending_up_rounded,
                const Color(0xFF10B981),
                isDark,
              ),
              _buildKPICard(
                'Total App Orders',
                '${adminProv.totalOrders}',
                Icons.local_shipping_outlined,
                const Color(0xFFF59E0B),
                isDark,
              ),
              _buildKPICard(
                'Registered Customers',
                '${adminProv.totalUsers}',
                Icons.people_alt_outlined,
                const Color(0xFF8B5CF6),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly Sales Trend Chart
          Text(
            'Monthly Revenue Trends (Jan - Dec)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sales Progression by Month',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Peak: Dec (₹28.6k)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: adminProv.monthlySales.map((item) {
                      final heightFraction = (item.sales / maxMonthlySales).clamp(0.1, 1.0);
                      final isPeak = item.month == 'Dec';
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${(item.sales / 1000).toStringAsFixed(1)}k',
                                style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 120 * heightFraction,
                                decoration: BoxDecoration(
                                  color: isPeak
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF4F46E5).withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.month,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category Share Breakdown
          Text(
            'Category Revenue Share',
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
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _buildCategoryProgress('Electronics & Gadgets', 0.42, '42%', const Color(0xFF4F46E5)),
                const SizedBox(height: 12),
                _buildCategoryProgress('Fashion & Apparel', 0.28, '28%', const Color(0xFF10B981)),
                const SizedBox(height: 12),
                _buildCategoryProgress('Home & Lifestyle', 0.18, '18%', const Color(0xFFF59E0B)),
                const SizedBox(height: 12),
                _buildCategoryProgress('Books & Stationery', 0.12, '12%', const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(
      String label, double progress, String percentStr, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(percentStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildSellersTab(
      ThemeData theme, bool isDark, AdminProvider adminProv) {
    final apps = adminProv.sellerApplications;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final app = apps[index];
        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      app.storeName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: app.isApproved
                            ? const Color(0xFF10B981).withOpacity(0.12)
                            : const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        app.isApproved ? 'APPROVED' : 'PENDING REVIEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: app.isApproved
                              ? const Color(0xFF047857)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Merchant: ${app.applicantName} • ${app.email}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  'GSTIN: ${app.gstin}  •  Category: ${app.category}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                if (!app.isApproved) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          adminProv.rejectSeller(app.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Application rejected')),
                          );
                        },
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          adminProv.approveSeller(app.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF10B981),
                              content: Text('Seller approved and merchant credentials generated!'),
                            ),
                          );
                        },
                        child: const Text('Approve Store'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserModerationTab(
      ThemeData theme, bool isDark, AdminProvider adminProv) {
    final sampleUsers = [
      {'uid': 'usr_001', 'name': 'Aditya Verma', 'email': 'aditya@example.com', 'orders': 14},
      {'uid': 'usr_002', 'name': 'Sneha Kulkarni', 'email': 'sneha@example.com', 'orders': 8},
      {'uid': 'usr_003', 'name': 'Rohan Das', 'email': 'rohan.das@example.com', 'orders': 22},
      {'uid': 'usr_004', 'name': 'Pooja Sharma', 'email': 'pooja@example.com', 'orders': 2},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sampleUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final u = sampleUsers[index];
        final uid = u['uid'] as String;
        final isBlocked = adminProv.isUserBlocked(uid);

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isBlocked ? Colors.red.shade100 : const Color(0xFFEEF2FF),
              child: Icon(
                isBlocked ? Icons.block : Icons.person,
                color: isBlocked ? Colors.red : const Color(0xFF4F46E5),
              ),
            ),
            title: Text(
              u['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isBlocked ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text('${u['email']} • ${u['orders']} orders placed'),
            trailing: Switch(
              value: !isBlocked,
              activeColor: const Color(0xFF10B981),
              onChanged: (_) {
                adminProv.toggleBlockUser(uid);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBlocked ? 'User unblocked successfully' : 'User account suspended / blocked',
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCouponsTab(ThemeData theme, bool isDark) {
    final coupons = [
      {'code': 'WELCOME50', 'desc': '50% Flat Off up to ₹200 for new accounts', 'active': true},
      {'code': 'EASE20', 'desc': '20% Off on orders above ₹999', 'active': true},
      {'code': 'FREESHIP', 'desc': '100% Free Shipping waiver', 'active': true},
      {'code': 'FESTIVE10', 'desc': '10% Festive season storewide cashback', 'active': true},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = coupons[index];
        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.3)),
                  ),
                  child: Text(
                    c['code'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['desc'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Status: Active • Unlimited uses',
                        style: TextStyle(fontSize: 11, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSiteSettingsTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Marketplace Financial Governance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.percent_rounded, color: Color(0xFF4F46E5)),
                  title: const Text('Platform Commission Fee'),
                  subtitle: const Text('Deducted automatically from seller payouts'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('10.0%', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_outlined, color: Color(0xFF10B981)),
                  title: const Text('GST / VAT Tax Rate'),
                  subtitle: const Text('Calculated at checkout (CGST 9% + SGST 9%)'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('18.0%', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_shipping_outlined, color: Color(0xFFF59E0B)),
                  title: const Text('Free Shipping Order Threshold'),
                  subtitle: const Text('Orders above this amount receive free delivery'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('₹499 (or \$50)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Site Security & Maintenance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('AI Content & Review Moderation'),
                  subtitle: const Text('Auto-quarantine flagged reviews with abusive language'),
                  value: true,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) {},
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Developer Bypass PIN Mode'),
                  subtitle: const Text('PIN 7266 developer access active for testing'),
                  value: true,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (val) {},
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Marketplace Maintenance Mode'),
                  subtitle: const Text('Display scheduled maintenance banner to customers'),
                  value: false,
                  activeColor: Colors.red,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Maintenance mode ${val ? "enabled" : "disabled"}')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticsFleetTab(ThemeData theme, bool isDark) {
    final riders = [
      {'name': 'Abhishek StarRider', 'vehicle': 'DL 01 ST 7266', 'rating': 4.9, 'trips': 29, 'status': 'Delivering Order #DELIV-7266-01'},
      {'name': 'Vikram Singh', 'vehicle': 'HR 26 AB 1042', 'rating': 4.8, 'trips': 142, 'status': 'Available'},
      {'name': 'Rahul Verma', 'vehicle': 'UP 16 CD 8931', 'rating': 4.7, 'trips': 88, 'status': 'In Transit to Hub'},
      {'name': 'Deepak Kumar', 'vehicle': 'DL 04 EF 5521', 'rating': 5.0, 'trips': 210, 'status': 'Available'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'StarShop Fleet Network',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              const Text(
                'Real-time logistics monitoring and delivery partner SLA tracker.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Column(
                    children: [
                      Text('18', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('Active Riders', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('98.4%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('On-Time SLA', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('24 min', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('Avg Drop Time', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Active Fleet Riders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...riders.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE6F4EA),
                  child: Icon(Icons.two_wheeler, color: Color(0xFF059669)),
                ),
                title: Text(
                  r['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Vehicle: ${r['vehicle']} • ★ ${r['rating']} (${r['trips']} trips)\n${r['status']}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  tooltip: 'Contact Rider',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Connecting to ${r['name']}...')),
                    );
                  },
                ),
              ),
            )),
      ],
    );
  }
}
