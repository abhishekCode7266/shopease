import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> _items = [];
  String? _userId;
  bool _isLoading = false;
  StreamSubscription<List<CartItemModel>>? _cartSubscription;

  CartProvider({String? initialUserId}) {
    if (initialUserId != null) {
      updateUser(initialUserId);
    }
  }

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _isLoading;

  // Number of distinct items
  int get itemCount => _items.length;

  // Total quantity of all items combined
  int get totalQuantity =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  // Subtotal of cart
  double get subtotal =>
      _items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);

  // Estimated tax (8%)
  double get tax => subtotal * 0.08;

  // Shipping fee (Free if subtotal >= 50, otherwise $5.00)
  double get shippingFee => (subtotal >= 50.0 || _items.isEmpty) ? 0.0 : 5.00;

  // Total price
  double get grandTotal => subtotal + tax + shippingFee;

  // Update user ID and attach Firestore stream
  void updateUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _cartSubscription?.cancel();

    if (_userId != null && _userId!.isNotEmpty) {
      _isLoading = true;
      notifyListeners();

      _cartSubscription = _cartService.getCartStream(_userId!).listen(
        (firestoreItems) {
          _items = firestoreItems;
          _isLoading = false;
          notifyListeners();
        },
        onError: (_) {
          _isLoading = false;
          notifyListeners();
        },
      );
    } else {
      _items = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add product to cart
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    if (_userId != null && _userId!.isNotEmpty) {
      await _cartService.addToCart(_userId!, product, quantity: quantity);
    } else {
      // Local fallback
      final index = _items.indexWhere((i) => i.productId == product.id);
      if (index >= 0) {
        final existing = _items[index];
        _items[index] = existing.copyWith(quantity: existing.quantity + quantity);
      } else {
        _items.add(
          CartItemModel(
            productId: product.id,
            name: product.name,
            price: product.price,
            imageUrl: product.imageUrl,
            quantity: quantity,
          ),
        );
      }
      notifyListeners();
    }
  }

  // Update quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    if (_userId != null && _userId!.isNotEmpty) {
      await _cartService.updateQuantity(_userId!, productId, quantity);
    } else {
      final index = _items.indexWhere((i) => i.productId == productId);
      if (index >= 0) {
        _items[index] = _items[index].copyWith(quantity: quantity);
        notifyListeners();
      }
    }
  }

  // Remove single item
  Future<void> removeItem(String productId) async {
    if (_userId != null && _userId!.isNotEmpty) {
      await _cartService.removeFromCart(_userId!, productId);
    } else {
      _items.removeWhere((i) => i.productId == productId);
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    if (_userId != null && _userId!.isNotEmpty) {
      await _cartService.clearCart(_userId!);
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
