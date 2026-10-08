import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/developer_bypass_sheet.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/product_card.dart';
import '../../widgets/star_shop_logo.dart';
import '../admin/admin_dashboard_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../cart/cart_screen.dart';
import '../notifications/notification_center_screen.dart';
import '../orders/orders_screen.dart';
import '../product/product_compare_screen.dart';
import '../product/product_detail_screen.dart';
import '../profile/addresses_screen.dart';
import '../profile/profile_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../wishlist/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeFeedView(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cart.totalQuantity > 0,
              label: Text('${cart.totalQuantity}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cart.totalQuantity > 0,
              label: Text('${cart.totalQuantity}'),
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeFeedView extends StatelessWidget {
  const _HomeFeedView();

  void _openFilterBottomSheet(BuildContext context) {
    final prodProv = context.read<ProductProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final theme = Theme.of(modalCtx);
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters & Sorting',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            prodProv.resetFilters();
                            Navigator.pop(modalCtx);
                          },
                          child: const Text('Reset All'),
                        ),
                      ],
                    ),
                    const Divider(),

                    // Sort By
                    const Text('Sort By',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        {'key': 'popular', 'label': 'Most Popular'},
                        {'key': 'price_asc', 'label': 'Price: Low to High'},
                        {'key': 'price_desc', 'label': 'Price: High to Low'},
                        {'key': 'rating', 'label': 'Top Rated'},
                        {'key': 'discount', 'label': 'Biggest Discount'},
                      ].map((item) {
                        final isSel = prodProv.sortBy == item['key'];
                        return ChoiceChip(
                          label: Text(item['label']!),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) {
                              prodProv.setSortBy(item['key']!);
                              setModalState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Price Range Slider
                    Text(
                      'Max Price: ${AppConstants.currencySymbol}${prodProv.maxPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: prodProv.maxPrice.clamp(10.0, 300.0),
                      min: 10.0,
                      max: 300.0,
                      divisions: 29,
                      label: '${AppConstants.currencySymbol}${prodProv.maxPrice.toStringAsFixed(0)}',
                      onChanged: (val) {
                        prodProv.setPriceRange(0.0, val);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 12),

                    // Rating Filter
                    const Text('Minimum Rating',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [0.0, 3.0, 4.0, 4.5].map((r) {
                        final isSel = prodProv.minRating == r;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(r == 0.0 ? 'All' : '★ ${r.toStringAsFixed(1)}+'),
                            selected: isSel,
                            onSelected: (val) {
                              if (val) {
                                prodProv.setMinRating(r);
                                setModalState(() {});
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // In Stock Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show In-Stock Only',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      value: prodProv.onlyInStock,
                      onChanged: (val) {
                        prodProv.setOnlyInStock(val);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(modalCtx),
                        child: Text(
                          'Show ${prodProv.filteredProducts.length} Results',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final productProv = context.watch<ProductProvider>();
    final notifProv = context.watch<NotificationProvider>();
    final authProv = context.watch<AuthProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const StarShopLogo(size: 28),
        actions: [
          // Developer Bypass Circular Button
          IconButton(
            tooltip: 'Developer PIN 7266 Bypass',
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
              ),
              child: const Icon(Icons.code_rounded, color: Colors.white, size: 16),
            ),
            onPressed: () => DeveloperBypassSheet.show(context),
          ),

          // AI Concierge Tool
          IconButton(
            tooltip: 'StarShop AI Concierge',
            icon: const Icon(Icons.auto_awesome, color: Color(0xFF6366F1)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIAssistantScreen()),
              );
            },
          ),

          // Wishlist Shortcut
          IconButton(
            tooltip: 'Wishlist',
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),

          // Notification Center
          IconButton(
            tooltip: 'Notifications',
            icon: Badge(
              isLabelVisible: notifProv.unreadCount > 0,
              label: Text('${notifProv.unreadCount}'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationCenterScreen()),
              );
            },
          ),

          // Theme Toggle
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              themeProv.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              themeProv.toggleTheme(!themeProv.isDarkMode);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await productProv.seedProducts(silent: true);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar + Filter Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => productProv.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search 12+ products, headphones, books...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 22),
                          suffixIcon: productProv.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () =>
                                      productProv.setSearchQuery(''),
                                )
                              : null,
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: productProv.hasActiveFilters
                            ? const Color(0xFF4F46E5)
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        tooltip: 'Filter & Sort Products',
                        icon: Icon(
                          Icons.tune_rounded,
                          color: productProv.hasActiveFilters
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                        onPressed: () => _openFilterBottomSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Portal Navigation Bar (Admin / Seller / Compare / AI)
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildPortalChip(
                      icon: Icons.auto_awesome,
                      label: 'AI Concierge',
                      color: const Color(0xFF6366F1),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AIAssistantScreen()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPortalChip(
                      icon: Icons.compare_arrows_rounded,
                      label: 'Compare Specs',
                      color: const Color(0xFF0EA5E9),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProductCompareScreen()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPortalChip(
                      icon: Icons.storefront_rounded,
                      label: 'Seller Hub',
                      color: const Color(0xFF10B981),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SellerDashboardScreen()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPortalChip(
                      icon: Icons.admin_panel_settings_rounded,
                      label: 'Admin Central',
                      color: const Color(0xFFF59E0B),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPortalChip(
                      icon: Icons.location_on_outlined,
                      label: 'My Addresses',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddressesScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Promotional Mega Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LIMITED TIME OFFER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '50% OFF Festive Season',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Use coupon code WELCOME50 at checkout',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          productProv.setSortBy('discount');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Displaying highest discounted items!'),
                            ),
                          );
                        },
                        child: const Text('Shop Deals',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Recently Viewed Row (if any)
            if (productProv.recentlyViewed.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recently Viewed',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${productProv.recentlyViewed.length} items',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 90,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: productProv.recentlyViewed.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) {
                      final item = productProv.recentlyViewed[idx];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: item),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 30),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Category Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = AppConstants.categories[idx];
                    final isSelected = productProv.selectedCategory == cat;

                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: Icon(
                        AppConstants.getCategoryIcon(cat),
                        size: 16,
                        color: isSelected ? Colors.white : theme.colorScheme.primary,
                      ),
                      label: Text(cat),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : const Color(0xFF1E293B)),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      selectedColor: theme.colorScheme.primary,
                      onSelected: (_) => productProv.selectCategory(cat),
                    );
                  },
                ),
              ),
            ),

            // Products Content
            if (productProv.isLoading)
              const SliverFillRemaining(
                child: LoadingView(message: 'Loading products...'),
              )
            else if (productProv.filteredProducts.isEmpty)
              SliverFillRemaining(
                child: EmptyStateView(
                  icon: Icons.search_off_rounded,
                  title: 'No Products Found',
                  subtitle:
                      'No products matched your search or category filter. Try clearing filters.',
                  buttonText: 'Reset Filters',
                  onButtonPressed: () {
                    productProv.resetFilters();
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = productProv.filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                    childCount: productProv.filteredProducts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortalChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
