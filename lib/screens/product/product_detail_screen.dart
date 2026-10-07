import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';
import 'product_compare_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().addToRecentlyViewed(widget.product);
      }
    });
  }

  void _incrementQuantity() {
    if (_quantity < widget.product.stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _showVideoDemoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.play_circle_fill, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            const Text('Product Video Demo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.product.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.35),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: Color(0xFF4F46E5), size: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Interactive 4K 60FPS official showcase video simulation.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final product = widget.product;
    final isWishlisted = auth.isInWishlist(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Compare Specs',
            icon: const Icon(Icons.compare_arrows_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductCompareScreen(initialProduct: product),
                ),
              );
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: cart.totalQuantity > 0,
              label: Text('${cart.totalQuantity}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large Product Image with Overlay Wishlist & Video Buttons
                  Stack(
                    children: [
                      Hero(
                        tag: 'product_image_${product.id}',
                        child: SizedBox(
                          height: 320,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              child: const Center(
                                child:
                                    Icon(Icons.broken_image_outlined, size: 64),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Wishlist Floating Button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A).withOpacity(0.8)
                                : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted
                                  ? const Color(0xFFEF4444)
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                            onPressed: () {
                              auth.toggleWishlist(product.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 1),
                                  content: Text(
                                    isWishlisted
                                        ? 'Removed from wishlist'
                                        : 'Saved to wishlist!',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Video Demo Action Chip
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: InkWell(
                          onTap: _showVideoDemoDialog,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_circle_filled,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Watch Video Demo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Details Container
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Chip & Stock Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                product.category,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: product.stock > 0
                                    ? const Color(0xFF10B981).withOpacity(0.12)
                                    : const Color(0xFFEF4444).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                product.stock > 0
                                    ? 'In Stock (${product.stock} units)'
                                    : 'Out of Stock',
                                style: TextStyle(
                                  color: product.stock > 0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Rating & Reviews Row + Compare Action
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${product.reviewCount} verified reviews',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.6),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductCompareScreen(
                                        initialProduct: product),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.compare_arrows, size: 16),
                              label: const Text('Compare',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Price & Discount Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if (product.originalPrice != null &&
                                product.originalPrice! > product.price) ...[
                              const SizedBox(width: 10),
                              Text(
                                '${AppConstants.currencySymbol}${product.originalPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${product.discountPercent}% OFF',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Inclusive of all GST taxes  •  Free Delivery on orders above ₹50',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const Divider(height: 32),

                        // Verified Merchant Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFF10B981),
                                child: Icon(Icons.store,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sold by: ${product.sellerName}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Row(
                                      children: [
                                        Icon(Icons.verified,
                                            size: 12,
                                            color: Color(0xFF10B981)),
                                        SizedBox(width: 4),
                                        Text(
                                          'ShopEase Assured Merchant  •  4.9 ★ Rating',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Quantity Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: _decrementQuantity,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      '$_quantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: _incrementQuantity,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // Description
                        const Text(
                          'Product Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Specifications Table
                        if (product.specs != null &&
                            product.specs!.isNotEmpty) ...[
                          const Text(
                            'Technical Specifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
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
                            child: Column(
                              children: product.specs!.entries.map((e) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFF1F5F9),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          e.key,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          e.value,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Customer Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Customer Reviews & Ratings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '★ ${product.rating} / 5.0',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (product.reviews == null ||
                            product.reviews!.isEmpty) ...[
                          const Text('No reviews yet. Be the first to review!'),
                        ] else ...[
                          Column(
                            children: product.reviews!.map((r) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          r.userName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy')
                                              .format(r.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Row(
                                          children: List.generate(
                                            5,
                                            (starIdx) => Icon(
                                              starIdx < r.rating.toInt()
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              size: 14,
                                              color: const Color(0xFFF59E0B),
                                            ),
                                          ),
                                        ),
                                        if (r.verifiedPurchase) ...[
                                          const SizedBox(width: 8),
                                          const Text(
                                            '• Verified Buyer',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF10B981),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      r.comment,
                                      style: const TextStyle(
                                          fontSize: 13, height: 1.4),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Add to Cart Button
                  Expanded(
                    child: CustomButton(
                      text: 'Add to Cart',
                      isOutlined: true,
                      icon: Icons.add_shopping_cart_rounded,
                      onPressed: product.stock > 0
                          ? () {
                              cart.addToCart(product, quantity: _quantity);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added $_quantity to cart!'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    textColor: Colors.amber,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const CartScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Buy Now Button
                  Expanded(
                    child: CustomButton(
                      text: 'Buy Now',
                      icon: Icons.flash_on_rounded,
                      onPressed: product.stock > 0
                          ? () async {
                              await cart.addToCart(product, quantity: _quantity);
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                              }
                            }
                          : null,
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
}
