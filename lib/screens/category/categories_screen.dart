import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_theme.dart';
import '../product/product_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final void Function(String category)? onCategorySelected;

  const CategoriesScreen({super.key, this.onCategorySelected});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedCategory = 'Electronics';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Electronics',
      'icon': Icons.devices,
      'color': const Color(0xFF1E88E5),
      'count': 18,
      'subcategories': ['Headphones', 'Smart Watches', 'Audio', 'Laptops', 'Cameras'],
    },
    {
      'name': 'Fashion',
      'icon': Icons.checkroom,
      'color': const Color(0xFFE91E63),
      'count': 24,
      'subcategories': ['Men Clothing', 'Women Clothing', 'Footwear', 'Watches', 'Bags'],
    },
    {
      'name': 'Home',
      'icon': Icons.home,
      'color': const Color(0xFF43A047),
      'count': 15,
      'subcategories': ['Decor', 'Kitchenware', 'Furniture', 'Lighting', 'Bedding'],
    },
    {
      'name': 'Beauty',
      'icon': Icons.spa,
      'color': const Color(0xFF8E24AA),
      'count': 12,
      'subcategories': ['Skincare', 'Fragrances', 'Haircare', 'Makeup', 'Wellness'],
    },
    {
      'name': 'Books',
      'icon': Icons.menu_book,
      'color': const Color(0xFFFF8F00),
      'count': 9,
      'subcategories': ['Fiction', 'Non-Fiction', 'Tech & Coding', 'Self Help', 'Comics'],
    },
    {
      'name': 'Sports',
      'icon': Icons.sports_basketball,
      'color': const Color(0xFF00ACC1),
      'count': 14,
      'subcategories': ['Fitness Equipment', 'Outdoor Gear', 'Sportswear', 'Cycling', 'Gym'],
    },
    {
      'name': 'Toys',
      'icon': Icons.smart_toy,
      'color': const Color(0xFFFF5722),
      'count': 8,
      'subcategories': ['Board Games', 'Action Figures', 'STEM Toys', 'Puzzles', 'Plush'],
    },
    {
      'name': 'Grocery',
      'icon': Icons.local_grocery_store,
      'color': const Color(0xFF388E3C),
      'count': 20,
      'subcategories': ['Organic Snacks', 'Beverages', 'Dry Fruits', 'Coffee & Tea', 'Spices'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProv = context.watch<ProductProvider>();
    final categoryProducts = productProv.products
        .where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'All Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Left Side Navigation rail / category list
          Container(
            width: 110,
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat['name'] == _selectedCategory;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name'] as String;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryOrange.withOpacity(0.12)
                          : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryOrange
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              (cat['color'] as Color).withOpacity(0.15),
                          child: Icon(
                            cat['icon'] as IconData,
                            size: 20,
                            color: cat['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primaryOrange
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Right Content Area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategoryHeroBanner(),
                const SizedBox(height: 16),
                const Text(
                  'Explore Subcategories',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                _buildSubcategoriesChips(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedCategory Items (${categoryProducts.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (widget.onCategorySelected != null)
                      TextButton(
                        onPressed: () {
                          widget.onCategorySelected!(_selectedCategory);
                          Navigator.of(context).pop();
                        },
                        child: const Text('View All in Catalog'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (categoryProducts.isEmpty)
                  _buildEmptyCategoryNotice(productProv)
                else
                  _buildProductsGrid(categoryProducts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeroBanner() {
    final catData = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
      orElse: () => _categories[0],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            catData['color'] as Color,
            (catData['color'] as Color).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (catData['color'] as Color).withOpacity(0.3),
            blurRadius: 8,
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
                Text(
                  _selectedCategory,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Top curated products with verified warranty and fast express delivery.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            catData['icon'] as IconData,
            size: 48,
            color: Colors.white.withOpacity(0.85),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesChips() {
    final catData = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
      orElse: () => _categories[0],
    );
    final subcats = catData['subcategories'] as List<String>;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: subcats.map((sub) {
        return ActionChip(
          label: Text(sub, style: const TextStyle(fontSize: 12)),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 1,
          onPressed: () {
            if (widget.onCategorySelected != null) {
              widget.onCategorySelected!(_selectedCategory);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Filtered by $sub in $_selectedCategory'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCategoryNotice(ProductProvider prov) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 44, color: AppTheme.textMuted),
          const SizedBox(height: 8),
          Text(
            'New products arriving soon in $_selectedCategory',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check out our featured Electronics & Fashion in the meantime!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List products) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 13, color: Colors.amber),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
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
      },
    );
  }
}
