import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/models/cart_item_model.dart';
import 'package:shopease/models/product_model.dart';
import 'package:shopease/providers/cart_provider.dart';

void main() {
  group('Cart Calculation Tests', () {
    test('CartItemModel calculates total price correctly', () {
      final item = CartItemModel(
        productId: 'prod_1',
        name: 'Wireless Headphones',
        price: 99.99,
        imageUrl: 'https://example.com/item.jpg',
        quantity: 3,
      );

      expect(item.totalPrice, closeTo(299.97, 0.001));
    });

    test('CartProvider calculates subtotal, tax, shipping, and grand total', () async {
      final cart = CartProvider();

      expect(cart.subtotal, 0.0);
      expect(cart.tax, 0.0);
      expect(cart.shippingFee, 0.0);
      expect(cart.grandTotal, 0.0);
      expect(cart.isEmpty, isTrue);

      final p1 = ProductModel(
        id: 'p1',
        name: 'T-Shirt',
        price: 20.00,
        description: 'Cotton shirt',
        imageUrl: '',
        category: 'Fashion',
        rating: 4.5,
        stock: 10,
      );

      // Add item (under $50 threshold)
      await cart.addToCart(p1, quantity: 2); // 2 * $20 = $40
      expect(cart.subtotal, 40.00);
      expect(cart.tax, closeTo(3.20, 0.001)); // 8% of 40 = 3.20
      expect(cart.shippingFee, 5.00); // Less than 50 -> shipping fee 5.00
      expect(cart.grandTotal, closeTo(48.20, 0.001));

      // Increase quantity to reach free shipping threshold (> $50)
      await cart.addToCart(p1, quantity: 1); // 3 * $20 = $60
      expect(cart.subtotal, 60.00);
      expect(cart.tax, closeTo(4.80, 0.001)); // 8% of 60 = 4.80
      expect(cart.shippingFee, 0.00); // Free shipping!
      expect(cart.grandTotal, closeTo(64.80, 0.001));
    });

    test('Cart quantity updates and removal', () async {
      final cart = CartProvider();

      final p = ProductModel(
        id: 'p1',
        name: 'Sneakers',
        price: 75.00,
        description: 'Sports shoes',
        imageUrl: '',
        category: 'Sports',
        rating: 4.8,
        stock: 5,
      );

      await cart.addToCart(p, quantity: 1);
      expect(cart.totalQuantity, 1);

      await cart.updateQuantity('p1', 4);
      expect(cart.totalQuantity, 4);

      // Updating quantity to 0 removes the item
      await cart.updateQuantity('p1', 0);
      expect(cart.isEmpty, isTrue);
    });
  });
}
