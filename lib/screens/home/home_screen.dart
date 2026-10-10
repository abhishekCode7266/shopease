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
import '../category/categories_screen.dart';
import '../delivery/delivery_dashboard_screen.dart';
import '../notifications/notification_center_screen.dart';
import '../orders/orders_screen.dart';
import '../product/product_compare_screen.dart';
import '../product/product_detail_screen.dart';
import '../profile/addresses_screen.dart';
import '../profile/profile_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../wallet/wallet_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../../widgets/camera_search_modal.dart';
import '../../widgets/delivery_location_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeFeedView(),
    CategoriesScreen(),
    AIAssistantScreen(),
    CartScreen(),
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
          const NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Categories',
          ),
          const NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Search',
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
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeFeedView extends StatefulWidget {
  const _HomeFeedView();

  @override
  State<_HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<_HomeFeedView> {
  String _currentPin = '122002';
  String _currentLocationName = 'DLF Cyber City, Gurugram';
  double? _budgetLimit;

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

    final allProds = productProv.products;
    final trendingDeals = List<ProductModel>.from(allProds)
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    final fashionDeals = allProds
        .where((p) => p.category.toLowerCase().contains('fashion'))
        .toList();
    final bestsellers = List<ProductModel>.from(allProds)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final forYouPicks = allProds.where((p) => p.rating >= 4.5).toList();

    var displayProducts = productProv.filteredProducts;
    if (_budgetLimit != null) {
      displayProducts =
          displayProducts.where((p) => p.price <= _budgetLimit!).toList();
    }

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
      body: Column(
        children: [
          // 1. TOP DELIVERY LOCATION / PIN BANNER (Amazon / Flipkart Style)
          InkWell(
            onTap: () {
              DeliveryLocationSheet.show(
                context: context,
                currentPinCode: _currentPin,
                currentLocationName: _currentLocationName,
                onLocationSelected: (loc) {
                  setState(() {
                    _currentPin = loc['pin'] ?? '122002';
                    _currentLocationName = loc['name'] ?? 'Gurugram';
                  });
                },
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deliver to ${authProv.user?.name.split(" ").first ?? "Abhishek"} - $_currentLocationName ($_currentPin)',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: Color(0xFF4F46E5)),
                ],
              ),
            ),
          ),

          // Main Scrollable Feed
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await productProv.seedProducts(silent: true);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 2. SEARCH BAR WITH AI CAMERA VISUAL SEARCH ICON
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (val) =>
                                  productProv.setSearchQuery(val),
                              decoration: InputDecoration(
                                hintText:
                                    'Search 25+ categories, brands, specs...',
                                prefixIcon: const Icon(Icons.search_rounded,
                                    size: 22),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (productProv.searchQuery.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.clear_rounded,
                                            size: 18),
                                        onPressed: () =>
                                            productProv.setSearchQuery(''),
                                      ),
                                    IconButton(
                                      tooltip: 'AI Camera Visual Search',
                                      icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Color(0xFF4F46E5),
                                          size: 22),
                                      onPressed: () =>
                                          CameraSearchModal.show(context),
                                    ),
                                  ],
                                ),
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

                  // Smart Search Autocomplete Hints
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text(
                              'Trending: ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            ...[
                              'Headphones',
                              'Smart Watch',
                              'Chair',
                              'Sneakers',
                              'Lamp',
                              'Clean Code'
                            ].map(
                              (hint) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ActionChip(
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  label: Text(hint,
                                      style: const TextStyle(fontSize: 11)),
                                  onPressed: () =>
                                      productProv.setSearchQuery(hint),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Quick Portal Navigation Bar (Delivery / AI / Compare / Seller / Admin / Wallet)
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _buildPortalChip(
                            icon: Icons.two_wheeler_rounded,
                            label: 'Delivery Hub',
                            color: const Color(0xFF059669),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const DeliveryDashboardScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'StarShop Wallet',
                            color: const Color(0xFF10B981),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const WalletScreen()),
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
                                  builder: (_) =>
                                      const ProductCompareScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPortalChip(
                            icon: Icons.storefront_rounded,
                            label: 'Seller Hub',
                            color: const Color(0xFF8B5CF6),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SellerDashboardScreen()),
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
                                  builder: (_) =>
                                      const AdminDashboardScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Category Filter Chips (Horizontal Rail)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final cat = AppConstants.categories[idx];
                          final isSelected =
                              productProv.selectedCategory == cat;

                          return FilterChip(
                            selected: isSelected,
                            showCheckmark: false,
                            avatar: Icon(
                              AppConstants.getCategoryIcon(cat),
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                            ),
                            label: Text(cat),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B)),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            selectedColor: theme.colorScheme.primary,
                            onSelected: (_) =>
                                productProv.selectCategory(cat),
                          );
                        },
                      ),
                    ),
                  ),

                  // 5. Promotional Mega Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
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
                                      'LIMITED TIME FESTIVAL OFFER',
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
                                    content: Text(
                                        'Displaying highest discounted items!'),
                                  ),
                                );
                              },
                              child: const Text('Shop Deals',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 6. FOR YOU / AI RECOMMENDED CAROUSEL
                  if (forYouPicks.isNotEmpty) ...[
                    _buildSectionHeaderSliver(
                      title: '✨ For You: AI Recommendations',
                      subtitle: 'Personalized based on your browsing pattern',
                      actionText: 'View All',
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AIAssistantScreen()),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 180,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: forYouPicks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, idx) {
                            return _buildHorizontalProductCard(
                              forYouPicks[idx],
                              isDark,
                              badge: 'AI PICK',
                              badgeColor: const Color(0xFF6366F1),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // 7. TRENDING PRODUCTS & DEALS OF THE DAY
                  if (trendingDeals.isNotEmpty) ...[
                    _buildSectionHeaderSliver(
                      title: '🔥 Deals of the Day (Up to 50% Off)',
                      subtitle: 'Ends in 05h : 24m : 18s • Lowest price guaranteed',
                      actionText: 'Explore',
                      onAction: () => productProv.setSortBy('discount'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 180,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: trendingDeals.take(8).length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, idx) {
                            final p = trendingDeals[idx];
                            return _buildHorizontalProductCard(
                              p,
                              isDark,
                              badge: '${p.discountPercent}% OFF',
                              badgeColor: const Color(0xFFEF4444),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // 8. FASHION DEALS (CALCULATED % SAVINGS)
                  if (fashionDeals.isNotEmpty) ...[
                    _buildSectionHeaderSliver(
                      title: '👗 Fashion Deals & Wardrobe Specials',
                      subtitle: 'Save up to 40% on top apparel & footwear',
                      actionText: 'Shop Fashion',
                      onAction: () =>
                          productProv.selectCategory('Fashion'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 180,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: fashionDeals.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, idx) {
                            final p = fashionDeals[idx];
                            return _buildHorizontalProductCard(
                              p,
                              isDark,
                              badge: 'SAVE ${p.discountPercent}%',
                              badgeColor: const Color(0xFFE91E63),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // 9. BESTSELLERS CAROUSEL
                  if (bestsellers.isNotEmpty) ...[
                    _buildSectionHeaderSliver(
                      title: '🏆 StarShop Bestsellers',
                      subtitle: 'Most loved products rated 4.7★ and above',
                      actionText: 'See All',
                      onAction: () => productProv.setMinRating(4.5),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 180,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: bestsellers.take(6).length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, idx) {
                            return _buildHorizontalProductCard(
                              bestsellers[idx],
                              isDark,
                              badge: 'BESTSELLER',
                              badgeColor: const Color(0xFF047857),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // 10. RECENTLY VIEWED ROW
                  if (productProv.recentlyViewed.isNotEmpty) ...[
                    _buildSectionHeaderSliver(
                      title: '🕒 Recently Viewed',
                      subtitle: 'Pick up where you left off',
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 90,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: productProv.recentlyViewed.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, idx) {
                            final item = productProv.recentlyViewed[idx];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailScreen(product: item),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 220,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
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
                                            const Icon(Icons.broken_image,
                                                size: 30),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
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

                  // 11. BUDGET SHOPPING (Under $50 / Under $100 / All)
                  _buildSectionHeaderSliver(
                    title: '🏷️ Budget Shopping Store',
                    subtitle: 'Great deals under your preferred price limit',
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Budget'),
                            selected: _budgetLimit == null,
                            onSelected: (val) {
                              if (val) setState(() => _budgetLimit = null);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('Under ${AppConstants.currencySymbol}50'),
                            selected: _budgetLimit == 50.0,
                            onSelected: (val) {
                              setState(() => _budgetLimit = val ? 50.0 : null);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('Under ${AppConstants.currencySymbol}100'),
                            selected: _budgetLimit == 100.0,
                            onSelected: (val) {
                              setState(
                                  () => _budgetLimit = val ? 100.0 : null);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // 12. ALL PRODUCTS / FILTERED RESULTS HEADER
                  _buildSectionHeaderSliver(
                    title: '📦 Explore Catalog (${displayProducts.length})',
                    subtitle: productProv.selectedCategory != 'All'
                        ? 'Category: ${productProv.selectedCategory}'
                        : 'Handpicked products across all categories',
                  ),

                  // Products Grid or Empty State
                  if (productProv.isLoading)
                    const SliverFillRemaining(
                      child: LoadingView(message: 'Loading products...'),
                    )
                  else if (displayProducts.isEmpty)
                    SliverFillRemaining(
                      child: EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No Products Found',
                        subtitle:
                            'No products matched your criteria. Try adjusting budget or category filters.',
                        buttonText: 'Reset All Filters',
                        onButtonPressed: () {
                          setState(() => _budgetLimit = null);
                          productProv.resetFilters();
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = displayProducts[index];
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
                          childCount: displayProducts.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderSliver({
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (actionText != null && onAction != null)
              TextButton(
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero),
                onPressed: onAction,
                child: Text(
                  actionText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalProductCard(
    ProductModel p,
    bool isDark, {
    required String badge,
    required Color badgeColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: p),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(13)),
                  child: Image.network(
                    p.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${AppConstants.currencySymbol}${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (p.originalPrice > p.price)
                        Text(
                          '${AppConstants.currencySymbol}${p.originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Colors.amber),
                      Text(
                        '${p.rating}',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${p.reviewCount})',
                        style:
                            const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
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
