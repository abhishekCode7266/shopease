import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/coupon_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService? _customCartService;
  CartService get _cartService => _customCartService ?? CartService();

  List<CartItemModel> _items = [];
  String? _userId;
  bool _isLoading = false;
  StreamSubscription<List<CartItemModel>>? _cartSubscription;

  CouponModel? _appliedCoupon;
  ShippingAddress? _selectedAddress;

  CartProvider({CartService? cartService, String? initialUserId})
      : _customCartService = cartService {
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

  CouponModel? get appliedCoupon => _appliedCoupon;
  ShippingAddress? get selectedAddress => _selectedAddress;

  // Discount calculation
  double get discountAmount => _appliedCoupon?.calculateDiscount(subtotal) ?? 0.0;

  // 18% GST (9% CGST + 9% SGST) calculated on discounted subtotal
  double get taxableAmount => (subtotal - discountAmount).clamp(0.0, double.infinity);
  double get cgst => taxableAmount * 0.09;
  double get sgst => taxableAmount * 0.09;
  double get tax => cgst + sgst;

  // Shipping fee (Free if subtotal >= 50 or coupon applied or empty, otherwise $5.00)
  double get shippingFee {
    if (_items.isEmpty) return 0.0;
    if (_appliedCoupon?.isFreeShipping == true) return 0.0;
    return subtotal >= 50.0 ? 0.0 : 5.00;
  }

  // Free shipping progress (0.0 to 1.0)
  double get freeShippingProgress => (subtotal / 50.0).clamp(0.0, 1.0);
  double get amountNeededForFreeShipping => (50.0 - subtotal).clamp(0.0, 50.0);

  // Total price
  double get grandTotal => (taxableAmount + tax + shippingFee).clamp(0.0, double.infinity);

  void setSelectedAddress(ShippingAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  String? applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    final coupon = CouponModel.availableCoupons.firstWhere(
      (c) => c.code == cleanCode,
      orElse: () => const CouponModel(code: '', title: '', description: ''),
    );

    if (coupon.code.isEmpty) {
      return 'Invalid coupon code. Try WELCOME50 or EASE20';
    }

    if (subtotal < coupon.minOrderAmount) {
      return 'Order subtotal must be at least \$${coupon.minOrderAmount.toStringAsFixed(0)} to use ${coupon.code}';
    }

    _appliedCoupon = coupon;
    notifyListeners();
    return null;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

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
      try {
        await _cartService.addToCart(_userId!, product, quantity: quantity);
      } catch (_) {
        _addToLocalCart(product, quantity);
      }
    } else {
      _addToLocalCart(product, quantity);
    }
  }

  void _addToLocalCart(ProductModel product, int quantity) {
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

  // Update quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    if (_userId != null && _userId!.isNotEmpty) {
      try {
        await _cartService.updateQuantity(_userId!, productId, quantity);
      } catch (_) {
        _updateLocalQuantity(productId, quantity);
      }
    } else {
      _updateLocalQuantity(productId, quantity);
    }
  }

  void _updateLocalQuantity(String productId, int quantity) {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  // Remove single item
  Future<void> removeItem(String productId) async {
    if (_userId != null && _userId!.isNotEmpty) {
      try {
        await _cartService.removeFromCart(_userId!, productId);
      } catch (_) {
        _items.removeWhere((i) => i.productId == productId);
        notifyListeners();
      }
    } else {
      _items.removeWhere((i) => i.productId == productId);
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    _appliedCoupon = null;
    if (_userId != null && _userId!.isNotEmpty) {
      try {
        await _cartService.clearCart(_userId!);
      } catch (_) {
        _items.clear();
        notifyListeners();
      }
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
