import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final productProv = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();

    final wishlistIds = auth.wishlistProductIds;
    final wishlistProducts = productProv.allProducts
        .where((p) => wishlistIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist (${wishlistProducts.length})'),
        actions: [
          if (wishlistProducts.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                for (final prod in wishlistProducts) {
                  cart.addToCart(prod);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${wishlistProducts.length} items to your cart!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('Add All to Cart'),
            ),
        ],
      ),
      body: wishlistProducts.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'Your Wishlist is Empty',
              subtitle:
                  'Explore the catalog and tap the heart icon to save products you love for later.',
              buttonText: 'Explore Catalog',
              onButtonPressed: () => Navigator.of(context).pop(),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: wishlistProducts.length,
              itemBuilder: (context, index) {
                final product = wishlistProducts[index];
                return Stack(
                  children: [
                    ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                          onPressed: () => auth.toggleWishlist(product.id),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
