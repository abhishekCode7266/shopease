import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddEditProductDialog({ProductModel? existing}) {
    final titleCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(
        text: existing != null ? existing.price.toStringAsFixed(2) : '');
    final origPriceCtrl = TextEditingController(
        text: existing?.originalPrice != null
            ? existing!.originalPrice!.toStringAsFixed(2)
            : '');
    final stockCtrl = TextEditingController(
        text: existing != null ? existing.stock.toString() : '20');
    final imgCtrl = TextEditingController(
        text: existing?.imageUrl ??
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600');
    String category = existing?.category ?? 'Electronics';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add New Product' : 'Edit Product'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.categories
                          .where((c) => c != 'All')
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price (${AppConstants.currencySymbol})',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: origPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Original / MRP',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock Units',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imgCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
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
                  final name = titleCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                  final origPrice =
                      double.tryParse(origPriceCtrl.text.trim());
                  final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                  final img = imgCtrl.text.trim();
                  final desc = descCtrl.text.trim();

                  if (name.isEmpty || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid product details')),
                    );
                    return;
                  }

                  final prodProv = context.read<ProductProvider>();
                  final auth = context.read<AuthProvider>();

                  if (existing == null) {
                    final newProd = ProductModel(
                      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      price: price,
                      originalPrice: origPrice ?? (price * 1.25),
                      description: desc,
                      imageUrl: img,
                      category: category,
                      rating: 4.8,
                      reviewCount: 1,
                      stock: stock,
                      sellerId: auth.currentUser?.id ?? 'seller_101',
                      sellerName: auth.currentUser?.sellerStoreName ?? 'StarShop Merchant Hub',
                    );
                    prodProv.addProduct(newProd);
                  } else {
                    final updated = existing.copyWith(
                      name: name,
                      price: price,
                      originalPrice: origPrice,
                      description: desc,
                      imageUrl: img,
                      category: category,
                      stock: stock,
                    );
                    prodProv.updateProduct(updated);
                  }

                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existing == null
                          ? 'Product created & live in catalogue!'
                          : 'Product updated successfully'),
                    ),
                  );
                },
                child: Text(existing == null ? 'Create' : 'Save Changes'),
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
    final authProv = context.watch<AuthProvider>();
    final prodProv = context.watch<ProductProvider>();
    final orderProv = context.watch<OrderProvider>();

    // Calculate metrics
    final totalProducts = prodProv.products.length;
    final inStockProducts = prodProv.products.where((p) => p.inStock).length;
    final totalOrders = orderProv.orders.length;
    final pendingOrders = orderProv.orders
        .where((o) =>
            o.status == AppConstants.orderStatusConfirmed ||
            o.status == AppConstants.orderStatusPacked)
        .length;
    final totalRevenue = orderProv.orders.fold<double>(
        0.0, (acc, o) => acc + (o.status != AppConstants.orderStatusCancelled ? o.total : 0.0));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront,
                  color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProv.currentUser?.sellerStoreName ?? 'StarShop Seller Hub',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Row(
                  children: [
                    Icon(Icons.verified, size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'Verified Merchant • Tier 1',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
            Tab(
              icon: const Icon(Icons.inventory_2_outlined),
              text: 'Products ($totalProducts)',
            ),
            Tab(
              icon: const Icon(Icons.local_shipping_outlined),
              text: 'Orders ($totalOrders)',
            ),
            const Tab(
              icon: const Icon(Icons.assessment_outlined),
              text: 'Reports',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overview Tab
          _buildOverviewTab(
            theme: theme,
            isDark: isDark,
            totalRevenue: totalRevenue,
            totalProducts: totalProducts,
            inStockProducts: inStockProducts,
            totalOrders: totalOrders,
            pendingOrders: pendingOrders,
          ),

          // 2. Products / Inventory Tab
          _buildProductsTab(theme, isDark, prodProv),

          // 3. Orders Management Tab
          _buildOrdersTab(theme, isDark, orderProv),

          // 4. Reports & Payouts Tab
          _buildReportsTab(theme, isDark, totalRevenue, totalOrders),
        ],
      ),
    );
  }

  Widget _buildOverviewTab({
    required ThemeData theme,
    required bool isDark,
    required double totalRevenue,
    required int totalProducts,
    required int inStockProducts,
    required int totalOrders,
    required int pendingOrders,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Highlight
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF047857), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
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
                    const Text(
                      'Total Net Earnings (Payouts)',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'This Month',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppConstants.currencySymbol}${totalRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      '+14.8% from last month  •  Next payout: 15th',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4 Metric Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Total Orders',
                '$totalOrders',
                Icons.shopping_bag_outlined,
                const Color(0xFF3B82F6),
                isDark,
              ),
              _buildMetricCard(
                'Action Needed',
                '$pendingOrders Pending',
                Icons.pending_actions_outlined,
                const Color(0xFFF59E0B),
                isDark,
              ),
              _buildMetricCard(
                'Active Catalog',
                '$totalProducts items',
                Icons.widgets_outlined,
                const Color(0xFF8B5CF6),
                isDark,
              ),
              _buildMetricCard(
                'Stock Health',
                '$inStockProducts In Stock',
                Icons.check_circle_outline,
                const Color(0xFF10B981),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
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
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Add Product'),
                  onPressed: () => _openAddEditProductDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Sales Report'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exporting Seller Monthly Report (CSV)...'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
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
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Icon(icon, color: color, size: 20),
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

  Widget _buildProductsTab(
      ThemeData theme, bool isDark, ProductProvider prodProv) {
    final prods = prodProv.products;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: prods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = prods[index];
        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    p.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppConstants.currencySymbol}${p.price.toStringAsFixed(2)}  •  ${p.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.inStock
                                  ? const Color(0xFF10B981).withOpacity(0.12)
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.inStock
                                  ? 'Stock: ${p.stock}'
                                  : 'Out of stock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: p.inStock
                                    ? const Color(0xFF047857)
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rating: ★ ${p.rating}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _openAddEditProductDialog(existing: p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  onPressed: () {
                    prodProv.deleteProduct(p.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product removed from catalog')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab(ThemeData theme, bool isDark, OrderProvider orderProv) {
    final orders = orderProv.orders;
    if (orders.isEmpty) {
      return const Center(child: Text('No orders received yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: order.status,
                      underline: const SizedBox(),
                      items: [
                        AppConstants.orderStatusConfirmed,
                        AppConstants.orderStatusPacked,
                        AppConstants.orderStatusShipped,
                        AppConstants.orderStatusOutForDelivery,
                        AppConstants.orderStatusDelivered,
                        AppConstants.orderStatusCancelled,
                      ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          orderProv.updateOrderStatus(order.id, newStatus);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order status set to $newStatus')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Customer: ${order.address.fullName} • ${order.address.city}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Items: ${order.items.map((i) => "${i.name} (x${i.quantity})").join(", ")}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${DateFormat('dd MMM, hh:mm a').format(order.createdAt)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    Text(
                      '${AppConstants.currencySymbol}${order.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsTab(
    ThemeData theme,
    bool isDark,
    double totalRevenue,
    int totalOrders,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settlement & Payout Reports',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _buildReportRow('Gross Sales Volume', totalRevenue),
                _buildReportRow('StarShop Commission (5%)', -totalRevenue * 0.05,
                    color: Colors.red),
                _buildReportRow('GST Collected (18%)', totalRevenue * 0.18),
                const Divider(height: 20),
                _buildReportRow(
                  'Net Payable to Merchant',
                  totalRevenue * 0.95,
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.cloud_download_outlined),
              label: const Text('Download Financial Ledger (.xlsx)'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Financial Ledger downloaded to device'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    String label,
    double amount, {
    Color? color,
    bool isBold = false,
  }) {
    final prefix = amount < 0 ? '-' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '$prefix${AppConstants.currencySymbol}${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
