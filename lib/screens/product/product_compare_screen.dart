import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/empty_state_view.dart';

class ProductCompareScreen extends StatelessWidget {
  const ProductCompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProv = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final comparedList = productProv.comparedProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare Products (${comparedList.length}/3)'),
        actions: [
          if (comparedList.isNotEmpty)
            IconButton(
              tooltip: 'Clear All',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => productProv.clearCompare(),
            ),
        ],
      ),
      body: comparedList.isEmpty
          ? EmptyStateView(
              icon: Icons.compare_arrows_rounded,
              title: 'No Products to Compare',
              message:
                  'Add up to 3 products to compare features, prices, and specifications side by side.',
              buttonText: 'Back to Shop',
              onButtonPressed: () => Navigator.of(context).pop(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Headers Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: comparedList.map((product) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () => productProv.removeFromCompare(product.id),
                                  child: const Icon(Icons.close_rounded, size: 18),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  cart.addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} added to cart!'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 11),
                                ),
                                child: const Text('Add to Cart'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Feature Comparison',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _buildComparisonRow(
                    context: context,
                    label: 'Category',
                    values: comparedList.map((p) => p.category).toList(),
                  ),
                  _buildComparisonRow(
                    context: context,
                    label: 'Rating',
                    values: comparedList.map((p) => '⭐ ${p.rating} (${p.reviewCount})').toList(),
                  ),
                  _buildComparisonRow(
                    context: context,
                    label: 'Discount',
                    values: comparedList.map((p) => '${p.discountPercent}% Off').toList(),
                  ),
                  _buildComparisonRow(
                    context: context,
                    label: 'Availability',
                    values: comparedList.map((p) => p.isInStock ? 'In Stock (${p.stock})' : 'Out of Stock').toList(),
                  ),
                  _buildComparisonRow(
                    context: context,
                    label: 'Seller',
                    values: comparedList.map((p) => p.sellerName).toList(),
                  ),

                  // Collect all specs keys
                  ..._getAllSpecKeys(comparedList).map((specKey) {
                    return _buildComparisonRow(
                      context: context,
                      label: specKey,
                      values: comparedList.map((p) => p.specs[specKey] ?? 'N/A').toList(),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Set<String> _getAllSpecKeys(List products) {
    final keys = <String>{};
    for (final p in products) {
      keys.addAll(p.specs.keys);
    }
    return keys;
  }

  Widget _buildComparisonRow({
    required BuildContext context,
    required String label,
    required List<String> values,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: values.map((val) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    val,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
